/*
 * pwm_measure.c : 실습 10-4  같은 핀(GPIO18)에 세 가지 PWM을 내고 계측기로 비교
 *
 * 회로 : GPIO18 (물리 핀 12) -> AD2 DIO 1 (Logic) 또는 Scope CH1(1+)
 *        GND (물리 핀 14)      -> AD2 GND
 * 빌드 : gcc -Wall -O2 -pthread -o pwm_measure pwm_measure.c -lpigpio -lrt
 * 실행 : sudo ./pwm_measure soft  1000 25     gpioPWM: 1 kHz 요청, 듀티 25 %
 *        sudo ./pwm_measure hard  1000 25     gpioHardwarePWM: 1 kHz, 25 %
 *        sudo ./pwm_measure servo 1500        gpioServo: 50 Hz, 펄스 1500 us
 *        Ctrl+C로 끝낸다.
 *
 * 프로그램이 출력하는 "실제 설정값"과 계측기로 잰 값을 표에 함께 기록한다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <pigpio.h>

#define PWM_GPIO 18            /* 물리 핀 12, 하드웨어 PWM0 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static void usage(void)
{
    fprintf(stderr, "사용법: sudo ./pwm_measure soft|hard <주파수Hz> <듀티%%>\n"
                    "        sudo ./pwm_measure servo <펄스폭us 500~2500>\n");
}

int main(int argc, char *argv[])
{
    const char *mode = (argc > 1) ? argv[1] : "";
    int a = (argc > 2) ? atoi(argv[2]) : 0;
    int b = (argc > 3) ? atoi(argv[3]) : 50;

    if (strcmp(mode, "soft") && strcmp(mode, "hard") && strcmp(mode, "servo")) {
        usage();
        return 1;
    }
    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    if (strcmp(mode, "soft") == 0) {
        /* DMA로 만드는 소프트웨어 PWM. 주파수는 정해진 표에서 가장 가까운 값으로 바뀐다. */
        int real_f, range;
        gpioSetMode(PWM_GPIO, PI_OUTPUT);
        real_f = gpioSetPWMfrequency(PWM_GPIO, (unsigned)a);
        range  = gpioGetPWMrange(PWM_GPIO);
        gpioPWM(PWM_GPIO, (unsigned)(range * b / 100));
        printf("gpioPWM: 요청 %d Hz -> 실제 %d Hz, range %d, real range %d, 듀티 %d %%\n",
               a, real_f, range, gpioGetPWMrealRange(PWM_GPIO), b);
    } else if (strcmp(mode, "hard") == 0) {
        /* PWM 주변장치가 직접 만드는 하드웨어 PWM. 듀티는 0~1000000. */
        if (gpioHardwarePWM(PWM_GPIO, (unsigned)a, (unsigned)(b * 10000)) != 0) {
            fprintf(stderr, "gpioHardwarePWM 실패(주파수 범위 확인)\n");
            gpioTerminate();
            return 1;
        }
        printf("gpioHardwarePWM: 요청 %d Hz -> 실제 %d Hz, 듀티 %d %%\n",
               a, gpioGetPWMfrequency(PWM_GPIO), b);
    } else {
        /* 서보 펄스: 50 Hz(20 ms 주기)에 폭 500~2500 us */
        if (gpioServo(PWM_GPIO, (unsigned)a) != 0) {
            fprintf(stderr, "gpioServo 실패(펄스폭 500~2500 us)\n");
            gpioTerminate();
            return 1;
        }
        printf("gpioServo: 50 Hz, 펄스폭 %d us\n", a);
    }
    printf("측정 후 Ctrl+C\n");

    while (running)
        gpioDelay(100000);

    if (strcmp(mode, "hard") == 0)
        gpioHardwarePWM(PWM_GPIO, 0, 0);
    else if (strcmp(mode, "servo") == 0)
        gpioServo(PWM_GPIO, 0);
    else
        gpioPWM(PWM_GPIO, 0);
    gpioSetMode(PWM_GPIO, PI_INPUT);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
