/*
 * button_alert.c : 실습 9-1(나)  알림 콜백(gpioSetAlertFunc)으로 버튼 누른 횟수 세기
 *
 * 회로 : 실습 9-1(가)와 같다 (버튼 GPIO26 - GND, LED GPIO17)
 * 동작 : 핀 레벨이 바뀔 때마다 pigpio가 on_button()을 불러 준다.
 *        main은 0.1초마다 깨어나 카운터가 바뀌었는지 보기만 한다.
 *        5초 동안 아무 변화가 없으면 워치독이 level = 2(PI_TIMEOUT)로 콜백을 부른다.
 * 빌드 : gcc -Wall -pthread -o button_alert button_alert.c -lpigpio -lrt
 * 실행 : sudo ./button_alert
 *
 * 원본 : Linux 백서 PIGIO 탭의 버튼 예제(gpioSetAlertFunc + LED 반전)에
 *        카운터, 눌림 간격(tick), 워치독, 종료 처리를 더했다.
 */
#include <stdio.h>
#include <signal.h>
#include <stdatomic.h>
#include <pigpio.h>

#define LED_GPIO     17        /* 물리 핀 11 */
#define BUTTON_GPIO  26        /* 물리 핀 37 */
#define WATCHDOG_MS  5000      /* 이 시간 동안 변화가 없으면 level 2 콜백 */

static volatile sig_atomic_t running = 1;

/* 콜백(pigpio 스레드)이 쓰고 main 스레드가 읽는 변수 -> atomic으로 선언 */
static atomic_uint presses;          /* 눌림 횟수 */
static atomic_uint last_gap_us;      /* 직전 눌림과의 간격(us) */
static atomic_uint timeouts;         /* 워치독 타임아웃 횟수 */

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* 콜백: 짧게! 세고, 기록하고, 바로 돌아간다. printf나 긴 지연은 넣지 않는다. */
static void on_button(int gpio, int level, uint32_t tick)
{
    static uint32_t prev_tick;       /* 콜백 안에서만 쓰므로 atomic이 필요 없다 */
    static int have_prev;
    unsigned n;

    (void)gpio;
    if (level == 0) {                            /* 1 -> 0 : 눌림 */
        n = atomic_fetch_add(&presses, 1) + 1;
        gpioWrite(LED_GPIO, n & 1);              /* LED 반전 */
        if (have_prev)
            atomic_store(&last_gap_us, tick - prev_tick);  /* 랩어라운드 안전 */
        prev_tick = tick;
        have_prev = 1;
    } else if (level == PI_TIMEOUT) {            /* 2 : 워치독 */
        atomic_fetch_add(&timeouts, 1);
    }
    /* level == 1 (뗌)은 여기서는 쓰지 않는다 */
}

int main(void)
{
    unsigned shown = 0, shown_to = 0, n, t;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패: sudo로 실행했는지, "
                        "pigpiod가 떠 있지 않은지 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(LED_GPIO, PI_OUTPUT);
    gpioWrite(LED_GPIO, 0);
    gpioSetMode(BUTTON_GPIO, PI_INPUT);
    gpioSetPullUpDown(BUTTON_GPIO, PI_PUD_UP);

    gpioSetAlertFunc(BUTTON_GPIO, on_button);    /* 콜백 등록 */
    gpioSetWatchdog(BUTTON_GPIO, WATCHDOG_MS);   /* 워치독 등록 */

    printf("버튼(GPIO%d)을 눌러 보라. Ctrl+C로 종료\n", BUTTON_GPIO);

    while (running) {
        n = atomic_load(&presses);
        if (n != shown) {
            printf("눌림 %u회 (직전 눌림과 %.3f초 간격)\n",
                   n, atomic_load(&last_gap_us) / 1e6);
            shown = n;
        }
        t = atomic_load(&timeouts);
        if (t != shown_to) {
            printf("  (%d초 동안 입력 없음: 워치독 %u회)\n", WATCHDOG_MS / 1000, t);
            shown_to = t;
        }
        gpioDelay(100000);                       /* main은 0.1초마다만 깨어난다 */
    }

    gpioSetWatchdog(BUTTON_GPIO, 0);             /* 워치독 해제 */
    gpioSetAlertFunc(BUTTON_GPIO, NULL);         /* 콜백 해제 */
    gpioWrite(LED_GPIO, 0);
    gpioSetMode(LED_GPIO, PI_INPUT);
    gpioTerminate();
    printf("\n총 눌림 %u회, 정상 종료\n", atomic_load(&presses));
    return 0;
}
