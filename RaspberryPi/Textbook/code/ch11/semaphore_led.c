/*
 * semaphore_led.c : 실습 11-6  세마포어로 "동시에 켜지는 LED는 최대 2개"를 보장 (pigpio)
 *
 * 회로 : LED 3개  GPIO17 (물리 핀 11), GPIO27 (물리 핀 13), GPIO22 (물리 핀 15)
 *                 각각 GPIO -> 330 Ω -> LED -> GND
 *        버튼     GPIO26 (물리 핀 37) -- 버튼 -- GND (물리 핀 39)
 *                 내부 풀업 사용 -> 누르면 0 (active-low, 8장 실습 8-3과 같은 배선)
 * 빌드 : gcc -Wall -O2 -pthread -o semaphore_led semaphore_led.c -lpigpio -lrt   (또는 make semaphore_led)
 * 실행 : sudo ./semaphore_led      버튼을 빠르게 여러 번 눌러 보라. Ctrl+C로 종료
 *
 * 원본 : Raspberry Pi Codes §4.1.7 semaphore_led.c (WiringPi)
 *        부록 B의 semaphore_led_pigpio.c(같은 표준 배선)와 같은 논리를 11장의 구성으로 다듬었다.
 * 고친 점
 *   1) 원본은 LED_3을 쓰지 않고, 모든 스레드가 LED_1과 LED_2를 "함께" 켜고 끈다.
 *      스레드가 1개든 2개든 LED 모양이 같아 세마포어의 효과가 보이지 않는다.
 *      -> LED 3개를 "자리(slot)"로 보고, 세마포어를 통과한 스레드가 빈 자리 하나를 골라
 *         그 LED만 켠다. 세마포어 초기값이 2이므로 켜진 LED는 언제나 2개 이하이다.
 *         빈 자리는 지난번 다음 자리부터 돌아가며 찾는다. 늘 첫 번째 빈 자리를 고르면
 *         LED0과 LED1만 번갈아 쓰이고 LED2는 영영 켜지지 않아 "3개 중 2개"가 보이지 않는다.
 *   2) 빈 자리 고르기도 공유 자원 접근이므로 뮤텍스로 보호한다(세마포어 = 몇 개까지, 뮤텍스 = 하나만).
 *   3) 스레드 번호는 malloc 대신 값 그대로(intptr_t) 넘긴다.
 *   4) 다른 스레드가 읽는 종료 플래그는 volatile이 아니라 atomic_int로 둔다(11.8절).
 *   5) Ctrl+C 시 모든 스레드가 끝난 것을 확인한 뒤 gpioTerminate()를 부른다.
 */
#include <stdio.h>
#include <stdint.h>
#include <signal.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdatomic.h>
#include <pigpio.h>

#define BUTTON_GPIO          26          /* 물리 핀 37 */
#define N_SLOTS              3
#define MAX_CONCURRENT_LEDS  2           /* 세마포어 초기값 */
#define ON_TIME_STEPS        30          /* 30 x 100 ms = 3초 점등 */

static const unsigned slot_gpio[N_SLOTS] = { 17, 27, 22 };   /* 물리 핀 11, 13, 15 */
static int slot_busy[N_SLOTS];                               /* 0 = 빈 자리 (slot_lock으로 보호) */
static int next_slot = 0;                                    /* 다음에 찾기 시작할 자리 (slot_lock으로 보호) */
static pthread_mutex_t slot_lock = PTHREAD_MUTEX_INITIALIZER;

static sem_t sem_led;
static atomic_int running = 1;           /* 시그널 함수가 쓰고 여러 스레드가 읽는다 */
static atomic_int outstanding = 0;       /* 아직 끝나지 않은 스레드 수 */

static void on_signal(int signum)        /* pigpio가 시그널 처리기 안에서 부른다: 플래그만 바꾼다 */
{
    (void)signum;
    atomic_store(&running, 0);
}

static void *blinkTask(void *arg)
{
    int id = (int)(intptr_t)arg;
    int slot = -1, i;

    printf("[요청] %d번 스레드: 빈 자리 대기 중...\n", id);
    sem_wait(&sem_led);                  /* P 연산: 자리가 없으면 여기서 잠든다 */

    if (atomic_load(&running)) {
        pthread_mutex_lock(&slot_lock);  /* 빈 LED 고르기 (임계 구역) */
        for (i = 0; i < N_SLOTS; i++) {
            int s = (next_slot + i) % N_SLOTS;   /* 돌아가며 찾는다 */
            if (!slot_busy[s]) {
                slot_busy[s] = 1;
                slot = s;
                next_slot = (s + 1) % N_SLOTS;
                break;
            }
        }
        pthread_mutex_unlock(&slot_lock);

        printf("  >> [진입] %d번 스레드: LED%d(GPIO%u) ON\n", id, slot, slot_gpio[slot]);
        gpioWrite(slot_gpio[slot], 1);
        for (i = 0; i < ON_TIME_STEPS && atomic_load(&running); i++)
            gpioDelay(100000);           /* 100 ms씩 나눠 자며 종료 요청을 확인 */
        gpioWrite(slot_gpio[slot], 0);

        pthread_mutex_lock(&slot_lock);
        slot_busy[slot] = 0;
        pthread_mutex_unlock(&slot_lock);
        printf("  << [반납] %d번 스레드: LED%d OFF\n", id, slot);
    }
    sem_post(&sem_led);                  /* V 연산: 자리 반납, 대기 스레드 하나를 깨움 */

    atomic_fetch_sub(&outstanding, 1);
    return NULL;
}

int main(void)
{
    pthread_t t_id;
    int task_count = 0, level, last = 1, i;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    for (i = 0; i < N_SLOTS; i++) {
        gpioSetMode(slot_gpio[i], PI_OUTPUT);
        gpioWrite(slot_gpio[i], 0);
    }
    gpioSetMode(BUTTON_GPIO, PI_INPUT);
    gpioSetPullUpDown(BUTTON_GPIO, PI_PUD_UP);     /* 내부 풀업: 떼면 1, 누르면 0 */

    sem_init(&sem_led, 0, MAX_CONCURRENT_LEDS);
    printf("=== 세마포어 LED (LED %d개, 동시 허용 %d개) - Ctrl+C로 종료 ===\n",
           N_SLOTS, MAX_CONCURRENT_LEDS);

    while (atomic_load(&running)) {
        level = gpioRead(BUTTON_GPIO);
        if (level == 0 && last == 1) {             /* 눌리는 순간(하강 에지)만 */
            task_count++;
            atomic_fetch_add(&outstanding, 1);
            if (pthread_create(&t_id, NULL, blinkTask, (void *)(intptr_t)task_count) == 0) {
                pthread_detach(t_id);              /* join하지 않는다: 끝나면 자원을 스스로 회수 */
            } else {
                printf("스레드 생성 실패!\n");
                atomic_fetch_sub(&outstanding, 1);
            }
            gpioDelay(50000);                      /* 50 ms: 채터링 무시 */
        }
        last = level;
        gpioDelay(10000);                          /* 10 ms 폴링 */
    }

    /* 종료: 점등 중인 스레드는 100 ms 안에 LED를 끄고 sem_post 한다.
     * 그 post가 대기 중인 스레드를 차례로 깨우고, 깬 스레드는 running == 0을 보고 바로 나간다. */
    for (i = 0; i < 50 && atomic_load(&outstanding) > 0; i++)
        gpioDelay(100000);                         /* 최대 5초 기다림 */

    for (i = 0; i < N_SLOTS; i++) {
        gpioWrite(slot_gpio[i], 0);
        gpioSetMode(slot_gpio[i], PI_INPUT);
    }
    sem_destroy(&sem_led);
    gpioTerminate();
    printf("\n정상 종료 (요청 %d건)\n", task_count);
    return 0;
}
