/*
 * led_fade.c : 실습 9-3  DMA PWM(gpioPWM)으로 LED 밝기 서서히 바꾸기
 *
 * 회로 : GPIO17 (물리 핀 11) -> 330 Ω -> LED -> GND (물리 핀 9)  (8장과 같다)
 * 동작 : 밝기 단계 0~100을 1초 동안 올리고 1초 동안 내리기를 반복한다.
 *          linear : 듀티를 단계에 정비례로 (사람 눈에는 금방 밝아지고 한참 그대로)
 *          gamma  : 듀티 = (단계/100)^2.2 (눈에 고르게 밝아지는 것처럼 보인다)
 * 빌드 : gcc -Wall -pthread -o led_fade led_fade.c -lpigpio -lrt -lm
 * 실행 : sudo ./led_fade gamma      (기본값)
 *        sudo ./led_fade linear
 *
 * 원본 : Linux 백서 PIGIO 탭의 PWM 예제(0~255를 5씩 증가)에
 *        주파수·범위 설정과 감마 보정을 더했다.
 */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <signal.h>
#include <pigpio.h>

#define LED_GPIO   17
#define PWM_FREQ   200         /* 요청 주파수(Hz). 기본 샘플링 5 us에서 실제 범위 1000 */
#define PWM_RANGE  1000        /* gpioPWM()에 줄 듀티의 최댓값 */
#define STEPS      100         /* 밝기 단계 수 */
#define STEP_US    10000       /* 단계마다 10 ms -> 100단계 = 1초 */
#define GAMMA      2.2

static volatile sig_atomic_t running = 1;
static unsigned table[STEPS + 1];          /* 단계 -> 듀티 변환표 */

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static void make_table(int use_gamma)
{
    for (int i = 0; i <= STEPS; i++) {
        double x = (double)i / STEPS;              /* 0.0 ~ 1.0 */
        if (use_gamma)
            x = pow(x, GAMMA);
        table[i] = (unsigned)lround(x * PWM_RANGE);
    }
}

int main(int argc, char *argv[])
{
    int use_gamma = !(argc > 1 && strcmp(argv[1], "linear") == 0);

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패: sudo로 실행했는지, "
                        "pigpiod가 떠 있지 않은지 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(LED_GPIO, PI_OUTPUT);
    gpioSetPWMfrequency(LED_GPIO, PWM_FREQ);       /* 18개 허용값 중 가장 가까운 값 */
    gpioSetPWMrange(LED_GPIO, PWM_RANGE);
    make_table(use_gamma);

    printf("모드 %s | 실제 주파수 %d Hz | 범위 %d | 실제 범위(해상도) %d\n",
           use_gamma ? "gamma" : "linear",
           gpioGetPWMfrequency(LED_GPIO),          /* 요청값이 아니라 실제 값 */
           gpioGetPWMrange(LED_GPIO),
           gpioGetPWMrealRange(LED_GPIO));
    printf("단계 10, 50, 90의 듀티: %u, %u, %u (/%d). Ctrl+C로 종료\n",
           table[10], table[50], table[90], PWM_RANGE);

    while (running) {
        for (int i = 0; i <= STEPS && running; i++) {         /* 밝아짐 */
            gpioPWM(LED_GPIO, table[i]);
            gpioDelay(STEP_US);
        }
        for (int i = STEPS; i >= 0 && running; i--) {         /* 어두워짐 */
            gpioPWM(LED_GPIO, table[i]);
            gpioDelay(STEP_US);
        }
    }

    gpioPWM(LED_GPIO, 0);                          /* PWM 정지 */
    gpioSetMode(LED_GPIO, PI_INPUT);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
