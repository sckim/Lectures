/*
 * button_queue.c : 실습 11-7  버튼 콜백(생산자) -> 큐 -> main 스레드(소비자)
 *
 * 회로 : 버튼  GPIO26 (물리 핀 37) -- 버튼 -- GND (물리 핀 39), 내부 풀업 -> 누르면 0
 *        LED   GPIO17 (물리 핀 11) -> 330 Ω -> LED -> GND
 * 빌드 : gcc -Wall -O2 -pthread -o button_queue button_queue.c -lpigpio -lrt   (또는 make button_queue)
 * 실행 : sudo ./button_queue        버튼을 눌러 보라. 누를 때마다 LED가 토글되고 기록이 찍힌다
 *
 * 구조 : pigpio의 알림(alert) 콜백은 pigpio가 만든 별도 스레드에서 실행된다(9장).
 *        콜백 안에서는 "언제, 무엇이" 일어났는지(level, tick)만 큐에 넣고 바로 돌아온다.
 *        printf, LED 제어, 파일 기록처럼 오래 걸리는 일은 main 스레드가 큐에서 꺼내서 한다.
 *        큐는 두 스레드가 함께 쓰는 자원이므로 뮤텍스로 보호하고, 조건 변수로 main을 깨운다.
 * 주의 : 콜백은 절대로 기다리면 안 된다. 큐가 가득 차면 기다리지 않고 버린 뒤 그 수를 센다.
 *        콜백 안에서 gpioRead()로 다시 읽지 않는다. 콜백의 level이 "그때"의 값이다(pigpio.h 설명).
 */
#include <stdio.h>
#include <stdint.h>
#include <signal.h>
#include <time.h>
#include <pthread.h>
#include <stdatomic.h>
#include <pigpio.h>

#define BUTTON_GPIO  26           /* 물리 핀 37 */
#define LED_GPIO     17           /* 물리 핀 11 */
#define QSIZE        16
#define GLITCH_US    10000        /* 10 ms 동안 안정된 변화만 알린다(채터링 제거, 9장) */

struct event {
    int level;                    /* 0 = 하강(누름), 1 = 상승(뗌) */
    uint32_t tick;                /* 변화가 일어난 시각 [us] (부팅 후, 약 72분마다 0으로 돌아감) */
};

static struct event queue[QSIZE];
static int head = 0, tail = 0, count = 0;
static unsigned dropped = 0;      /* 큐가 가득 차서 버린 이벤트 수 */
static pthread_mutex_t qlock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t  qcond;     /* main에서 CLOCK_MONOTONIC으로 초기화 */

static atomic_int running = 1;

static void on_signal(int signum)               /* 시그널 처리기 안: 플래그만 바꾼다 */
{
    (void)signum;
    atomic_store(&running, 0);
}

/* 생산자: pigpio 알림 스레드에서 실행된다. 짧게! */
static void on_button(int gpio, int level, uint32_t tick)
{
    (void)gpio;
    if (level == PI_TIMEOUT)                    /* 2 = 워치독 타임아웃(여기서는 안 씀) */
        return;

    pthread_mutex_lock(&qlock);
    if (count < QSIZE) {
        queue[tail].level = level;
        queue[tail].tick = tick;
        tail = (tail + 1) % QSIZE;
        count++;
        pthread_cond_signal(&qcond);            /* 소비자(main)를 깨운다 */
    } else {
        dropped++;                              /* 기다리지 않고 버린다 */
    }
    pthread_mutex_unlock(&qlock);
}

int main(void)
{
    pthread_condattr_t attr;
    uint32_t last_press = 0;
    int presses = 0, led = 0;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    pthread_condattr_init(&attr);
    pthread_condattr_setclock(&attr, CLOCK_MONOTONIC);   /* 시스템 시계가 바뀌어도 안전 */
    pthread_cond_init(&qcond, &attr);
    pthread_condattr_destroy(&attr);

    gpioSetMode(LED_GPIO, PI_OUTPUT);
    gpioWrite(LED_GPIO, 0);
    gpioSetMode(BUTTON_GPIO, PI_INPUT);
    gpioSetPullUpDown(BUTTON_GPIO, PI_PUD_UP);
    gpioGlitchFilter(BUTTON_GPIO, GLITCH_US);
    gpioSetAlertFunc(BUTTON_GPIO, on_button);           /* 이 순간부터 콜백이 불린다 */

    printf("버튼(GPIO%d)을 눌러 보라. Ctrl+C로 종료\n", BUTTON_GPIO);

    while (atomic_load(&running)) {
        struct event ev;
        struct timespec deadline;
        unsigned lost;

        pthread_mutex_lock(&qlock);
        while (count == 0 && atomic_load(&running)) {
            /* 200 ms마다 깨어나 종료 요청을 확인한다(시그널 처리기는 조건 변수를 깨울 수 없다) */
            clock_gettime(CLOCK_MONOTONIC, &deadline);
            deadline.tv_nsec += 200000000L;
            if (deadline.tv_nsec >= 1000000000L) {
                deadline.tv_nsec -= 1000000000L;
                deadline.tv_sec++;
            }
            pthread_cond_timedwait(&qcond, &qlock, &deadline);
        }
        if (count == 0) {                       /* 종료 요청으로 깨어났다 */
            pthread_mutex_unlock(&qlock);
            break;
        }
        ev = queue[head];
        head = (head + 1) % QSIZE;
        count--;
        lost = dropped;
        pthread_mutex_unlock(&qlock);           /* 꺼냈으면 바로 푼다. 아래 일은 잠금 밖에서 */

        /* ---- 소비자의 일: 시간이 걸려도 콜백을 막지 않는다 ---- */
        uint32_t delay_us = gpioTick() - ev.tick;   /* 사건 발생 -> 지금 처리까지 걸린 시간 */
        if (ev.level == 0) {
            presses++;
            led = !led;
            gpioWrite(LED_GPIO, led);
            printf("누름 #%-3d tick=%10u us  지난 누름과 간격 %7.1f ms  처리 지연 %u us  LED=%d",
                   presses, ev.tick,
                   presses > 1 ? (uint32_t)(ev.tick - last_press) / 1000.0 : 0.0,
                   delay_us, led);
            last_press = ev.tick;
        } else {
            printf("뗌         tick=%10u us                                처리 지연 %u us", ev.tick, delay_us);
        }
        if (lost)
            printf("  (버린 이벤트 %u개)", lost);
        printf("\n");
    }

    gpioSetAlertFunc(BUTTON_GPIO, NULL);        /* 콜백을 먼저 끊고 */
    gpioWrite(LED_GPIO, 0);
    gpioSetMode(LED_GPIO, PI_INPUT);
    gpioTerminate();                            /* 그다음 라이브러리를 정리한다 */
    pthread_cond_destroy(&qcond);
    printf("\n정상 종료 (누름 %d회)\n", presses);
    return 0;
}
