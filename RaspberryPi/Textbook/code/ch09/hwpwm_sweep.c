/*
 * hwpwm_sweep.c : 실습 9-4  하드웨어 PWM(gpioHardwarePWM)으로 주파수·듀티 바꾸기
 *
 * 회로 : GPIO18 (물리 핀 12, PWM 채널 0) -> 330 Ω -> LED -> GND (물리 핀 14)
 *        (수동 피에조 부저를 LED 대신 연결하면 주파수를 소리로 들을 수 있다)
 *        Analog Discovery 2를 쓰면 GPIO18과 GND를 Scope/Logic에 연결한다 (10장).
 * 빌드 : gcc -Wall -pthread -o hwpwm_sweep hwpwm_sweep.c -lpigpio -lrt
 * 실행 : sudo ./hwpwm_sweep                 자동 스윕 (듀티 스윕 -> 주파수 스윕)
 *        sudo ./hwpwm_sweep 1000 25         1000 Hz, 듀티 25 %로 고정 출력
 *
 * 원본 : 「Raspberry Pi 실습」 슬라이드의 gpioHardwarePWM 예제(1 kHz, 50 % -> 25 %)
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <pigpio.h>

#define PWM_GPIO    18             /* 하드웨어 PWM 가능 핀: 12, 13, 18, 19 */
#define PWM_CLK_HZ  375000000u     /* BCM2711(Pi 4)의 PWM 기준 클록. Pi 3 이하는 250 MHz */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* 주파수(Hz)와 듀티(%)로 하드웨어 PWM을 설정하고 실제 값을 보여 준다. */
static int set_pwm(unsigned freq, double duty_pct)
{
    unsigned duty = (unsigned)(duty_pct * 10000.0);      /* % -> 백만 분율 */
    int rc = gpioHardwarePWM(PWM_GPIO, freq, duty);
    unsigned steps;

    if (rc != 0) {
        fprintf(stderr, "gpioHardwarePWM 실패 (%d)\n", rc);
        return rc;
    }
    if (freq == 0) {                                      /* 주파수 0 = 끔 (0으로 나누기 방지) */
        printf("하드웨어 PWM 꺼짐\n");
        return 0;
    }
    steps = PWM_CLK_HZ / freq;                            /* 한 주기의 실제 단계 수 */
    printf("요청 %7u Hz, 듀티 %5.1f %% -> 단계 %9u개, 실제 주파수 %.2f Hz\n",
           freq, duty_pct, steps, (double)PWM_CLK_HZ / steps);
    return 0;
}

int main(int argc, char *argv[])
{
    static const unsigned freqs[] = { 50, 100, 1000, 10000, 100000 };

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패: sudo로 실행했는지, "
                        "pigpiod가 떠 있지 않은지 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    if (argc > 2) {                                       /* 고정 출력 모드 */
        if (set_pwm((unsigned)atoi(argv[1]), atof(argv[2])) == 0) {
            printf("출력 중. Ctrl+C로 종료\n");
            while (running)
                gpioDelay(100000);
        }
    } else {                                              /* 자동 스윕 모드 */
        printf("[1] 1 kHz에서 듀티 0 -> 100 %% (LED가 점점 밝아진다)\n");
        for (int d = 0; d <= 100 && running; d += 10) {
            set_pwm(1000, d);
            gpioDelay(500000);
        }
        printf("[2] 듀티 50 %%에서 주파수 바꾸기 (50 Hz에서는 깜빡임이 보인다)\n");
        for (unsigned i = 0; i < sizeof(freqs) / sizeof(freqs[0]) && running; i++) {
            set_pwm(freqs[i], 50.0);
            gpioDelay(2000000);
        }
    }

    gpioHardwarePWM(PWM_GPIO, 0, 0);                      /* 주파수 0 = 끔 */
    gpioSetMode(PWM_GPIO, PI_INPUT);                      /* ALT5에서 입력으로 되돌림 */
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
