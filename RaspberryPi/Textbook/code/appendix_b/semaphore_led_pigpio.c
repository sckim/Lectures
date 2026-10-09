/*
 * semaphore_led_pigpio.c : 부록 B  세마포어로 "동시에 켜지는 LED는 최대 2개"를 보장
 *
 * 회로 : LED 3개  LED0 GPIO17 (물리 핀 11), LED1 GPIO27 (물리 핀 13), LED2 GPIO22 (물리 핀 15)
 *                 각각 330 Ω + LED -> GND   (교재 표준 8-LED 바의 앞 세 개)
 *        버튼     BTN0: GPIO26 (물리 핀 37) -- 버튼 -- GND (물리 핀 39)
 *                 내부 풀업 사용 -> 누르면 0 (active-low, 교재 표준 배선)
 *        원본 배선(LED wPi 0·1·2 = GPIO17·18·27, 버튼 wPi 3 = GPIO22를 3.3 V 쪽에 달고
 *        풀다운, 누르면 1)에서 바꾸었다. 그래서 "눌림"은 상승 에지가 아니라 하강 에지이다.
 * 빌드 : gcc -Wall -pthread -o semaphore_led_pigpio semaphore_led_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./semaphore_led_pigpio      버튼을 빠르게 여러 번 눌러 보라
 *
 * 원본 : wiringpi/semaphore_led.c (저장소 Codes/semaphore_led.c, Raspberry Pi Codes §4.1.7)
 * 고친 점
 *   1) 원본은 LED_3을 쓰지 않고, 모든 스레드가 LED_1과 LED_2를 "함께" 켜고 끈다.
 *      그래서 스레드가 1개든 2개든 LED 모양이 같아 세마포어의 효과가 보이지 않는다.
 *      -> LED 3개를 "자리(slot)"로 보고, 세마포어를 통과한 스레드가 빈 자리 하나를
 *         골라 그 LED만 켠다. LED는 3개지만 세마포어 초기값이 2이므로 동시에
 *         켜지는 LED는 언제나 2개 이하이다. 세 번째 요청은 앞의 하나가 끝나야 켜진다.
 *         빈 자리는 지난번 다음 자리부터 돌아가며 찾는다. 늘 첫 번째 빈 자리를 고르면
 *         LED0과 LED1만 번갈아 쓰이고 LED2(GPIO22)는 영영 켜지지 않는다.
 *   2) 빈 자리를 고르는 일 자체도 공유 자원 접근이므로 뮤텍스로 보호한다.
 *      (세마포어는 "몇 개까지", 뮤텍스는 "한 번에 하나만" - 역할이 다르다)
 *   3) 스레드 번호를 malloc 대신 정수 값 그대로 인자에 실어 보낸다(intptr_t).
 *      지역 변수의 주소를 넘기지 않으므로 수명 문제가 없다.
 *   4) Ctrl+C 시 대기 중인 스레드까지 모두 끝난 것을 확인한 뒤 gpioTerminate()를 부른다.
 *      (스레드가 GPIO를 쓰는 중에 라이브러리를 정리하면 안 된다)
 *   5) 여러 스레드가 읽는 종료 플래그는 volatile이 아니라 atomic_int로 둔다.
 * 수정 : 처음 판은 늘 첫 번째 빈 자리를 골라 LED2가 켜지지 않았다. 돌아가며 고르도록
 *        고치고 종료 플래그를 atomic_int로 바꾸었다. 자세한 설명은 11장 실습 11-6
 *        (11_process_concurrency.md)을 보라.
 */
#include <stdio.h>
#include <stdint.h>
#include <signal.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdatomic.h>
#include <pigpio.h>

#define BUTTON_GPIO          26          /* BTN0, 물리 핀 37 (원본 wPi 3 = GPIO22) */
#define N_SLOTS              3
#define MAX_CONCURRENT_LEDS  2           /* 세마포어 초기값 */
#define ON_TIME_STEPS        30          /* 30 x 100 ms = 3초 점등 */

static const unsigned slot_gpio[N_SLOTS] = { 17, 27, 22 };   /* LED0, LED1, LED2 */
static int slot_busy[N_SLOTS];                               /* 0 = 빈 자리 */
static int next_slot = 0;                                    /* 다음에 찾기 시작할 자리 */
static pthread_mutex_t slot_lock = PTHREAD_MUTEX_INITIALIZER;

static sem_t sem_led;
static atomic_int running = 1;           /* 시그널 함수가 쓰고 여러 스레드가 읽는다 */

static int outstanding;                  /* 아직 끝나지 않은 스레드 수 */
static pthread_mutex_t count_lock = PTHREAD_MUTEX_INITIALIZER;

static void on_signal(int signum)
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
            int s = (next_slot + i) % N_SLOTS;   /* 지난번 다음 자리부터 돌아가며 */
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
            gpioDelay(100000);
        gpioWrite(slot_gpio[slot], 0);

        pthread_mutex_lock(&slot_lock);
        slot_busy[slot] = 0;
        pthread_mutex_unlock(&slot_lock);
        printf("  << [반납] %d번 스레드: LED%d OFF\n", id, slot);
    }
    sem_post(&sem_led);                  /* V 연산: 자리 반납, 대기 스레드 하나를 깨움 */

    pthread_mutex_lock(&count_lock);
    outstanding--;
    pthread_mutex_unlock(&count_lock);
    return NULL;
}

int main(void)
{
    pthread_t t_id;
    int task_count = 0, level, last, i, left;

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
    gpioSetPullUpDown(BUTTON_GPIO, PI_PUD_UP);     /* 원본 PUD_DOWN -> 풀업(active-low) */
    gpioDelay(1000);                               /* 1 ms: 풀업이 핀을 끌어올릴 시간 */
    last = gpioRead(BUTTON_GPIO);                  /* 시작 레벨을 실제로 읽어 둔다 */

    sem_init(&sem_led, 0, MAX_CONCURRENT_LEDS);
    printf("=== 세마포어 LED (LED %d개, 동시 허용 %d개) - Ctrl+C로 종료 ===\n",
           N_SLOTS, MAX_CONCURRENT_LEDS);

    while (atomic_load(&running)) {
        level = gpioRead(BUTTON_GPIO);
        if (level == 0 && last == 1) {             /* 눌리는 순간(하강 에지)만 */
            task_count++;
            pthread_mutex_lock(&count_lock);
            outstanding++;
            pthread_mutex_unlock(&count_lock);
            if (pthread_create(&t_id, NULL, blinkTask, (void *)(intptr_t)task_count) == 0) {
                pthread_detach(t_id);              /* 끝나면 자원을 스스로 회수 */
            } else {
                printf("스레드 생성 실패!\n");
                pthread_mutex_lock(&count_lock);
                outstanding--;
                pthread_mutex_unlock(&count_lock);
            }
            gpioDelay(50000);                      /* 50 ms: 채터링 무시 */
        }
        last = level;
        gpioDelay(10000);                          /* 10 ms 폴링 */
    }

    /* 종료: running = 0 이면 각 스레드는 100 ms 안에 LED를 끄고 sem_post 한다.
     * 그 post가 대기 중인 스레드를 차례로 깨우고, 깬 스레드는 곧바로 빠져나온다. */
    for (i = 0; i < 50; i++) {                     /* 최대 5초 기다림 */
        pthread_mutex_lock(&count_lock);
        left = outstanding;
        pthread_mutex_unlock(&count_lock);
        if (left == 0)
            break;
        gpioDelay(100000);
    }

    for (i = 0; i < N_SLOTS; i++) {
        gpioWrite(slot_gpio[i], 0);
        gpioSetMode(slot_gpio[i], PI_INPUT);
    }
    sem_destroy(&sem_led);
    gpioTerminate();
    printf("\n정상 종료 (요청 %d건)\n", task_count);
    return 0;
}
