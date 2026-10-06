/*
 * debounce_test.c : 실습 9-2  채터링(bounce) 관찰과 디바운스 비교
 *
 * 회로 : 버튼 GPIO26 (물리 핀 37) - GND (물리 핀 39), 내부 풀업 (실습 9-1과 같다)
 * 동작 : 버튼을 한 번 누르고 뗄 때마다(입력이 0.3초 조용해지면) 다음을 출력한다.
 *          - 들어온 에지 수(하강/상승)와 첫 에지~마지막 에지 시간(채터링 지속 시간)
 *          - 같은 에지 흐름에 소프트웨어 디바운스(tick 비교)를 적용해 센 눌림 수
 *        인자로 glitch 필터 시간을 주면 gpioGlitchFilter()를 켠 상태로 같은 측정을 한다.
 * 빌드 : gcc -Wall -pthread -o debounce_test debounce_test.c -lpigpio -lrt
 * 실행 : sudo ./debounce_test          필터 없음 (원래 신호)
 *        sudo ./debounce_test 5000     glitch 필터 5 ms
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <stdatomic.h>
#include <pigpio.h>

#define BUTTON_GPIO     26
#define QUIET_MS        300       /* 이만큼 조용하면 "한 번의 누름/뗌이 끝났다"고 본다 */
#define SW_DEBOUNCE_US  20000     /* 소프트웨어 디바운스: 직전 에지 후 20 ms 조용해야 인정 */

static volatile sig_atomic_t running = 1;

/* ---- 콜백 스레드 안에서만 쓰는 변수 (한 스레드만 쓰므로 atomic 불필요) ---- */
static unsigned b_fall, b_rise, b_press;   /* 이번 묶음(burst)의 하강·상승 에지, 인정된 눌림 */
static uint32_t b_first, b_last;           /* 이번 묶음의 첫 에지, 마지막 에지 tick */
static uint32_t last_edge_tick;            /* 소프트웨어 디바운스용: 직전 에지 tick */
static int have_edge;

/* ---- 콜백 -> main 으로 넘기는 보고서 ---- */
static unsigned r_fall, r_rise, r_press, r_span_us;
static atomic_int report_ready;            /* 1이면 main이 r_* 를 읽어 출력한다 */
static unsigned total_press;               /* main만 쓴다 */

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static void on_edge(int gpio, int level, uint32_t tick)
{
    (void)gpio;

    if (level == PI_TIMEOUT) {                     /* 워치독: QUIET_MS 동안 변화 없음 */
        if (b_fall + b_rise > 0 && !atomic_load(&report_ready)) {
            r_fall = b_fall;
            r_rise = b_rise;
            r_press = b_press;
            r_span_us = b_last - b_first;
            atomic_store(&report_ready, 1);      /* r_* 를 다 쓴 뒤에 깃발을 올린다 */
            b_fall = b_rise = b_press = 0;
        }
        return;
    }

    if (b_fall + b_rise == 0)
        b_first = tick;                          /* 묶음의 첫 에지 */
    b_last = tick;

    if (level == 0) {
        b_fall++;
        /* 소프트웨어 디바운스: 직전 에지로부터 충분히 조용했던 하강 에지만 "눌림" */
        if (!have_edge || (uint32_t)(tick - last_edge_tick) >= SW_DEBOUNCE_US)
            b_press++;
    } else {
        b_rise++;
    }
    last_edge_tick = tick;
    have_edge = 1;
}

int main(int argc, char *argv[])
{
    unsigned glitch_us = 0;

    if (argc > 1)
        glitch_us = (unsigned)atoi(argv[1]);

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패: sudo로 실행했는지, "
                        "pigpiod가 떠 있지 않은지 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(BUTTON_GPIO, PI_INPUT);
    gpioSetPullUpDown(BUTTON_GPIO, PI_PUD_UP);

    if (gpioGlitchFilter(BUTTON_GPIO, glitch_us) != 0) {   /* 0이면 필터 끔 */
        fprintf(stderr, "glitch 필터 값은 0~300000 us 이어야 한다.\n");
        gpioTerminate();
        return 1;
    }
    gpioSetAlertFunc(BUTTON_GPIO, on_edge);
    gpioSetWatchdog(BUTTON_GPIO, QUIET_MS);

    printf("glitch 필터 %u us. 버튼을 한 번씩 천천히 눌렀다 떼 보라. Ctrl+C로 종료\n",
           glitch_us);
    printf("%4s %6s %6s %10s %12s\n", "누적", "하강", "상승", "SW눌림", "지속(us)");

    while (running) {
        if (atomic_load(&report_ready)) {
            total_press += r_press;
            printf("%4u %6u %6u %10u %12u\n",
                   total_press, r_fall, r_rise, r_press, r_span_us);
            atomic_store(&report_ready, 0);
        }
        gpioDelay(20000);
    }

    gpioSetWatchdog(BUTTON_GPIO, 0);
    gpioSetAlertFunc(BUTTON_GPIO, NULL);
    gpioGlitchFilter(BUTTON_GPIO, 0);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
