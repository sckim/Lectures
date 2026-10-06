/*
 * pad_strength.c : 실습 10-2  GPIO 구동 세기(drive strength)를 바꾸며 V_OH와 에지를 측정
 *
 * 동작 : 1) GPIO0~27 묶음(pad 0)의 구동 세기를 인자로 준 값(2~16 mA)으로 바꾼다.
 *        2) GPIO17은 계속 High로 둔다     -> 부하 저항을 달고 Voltmeter/Scope로 V_OH 측정
 *        3) GPIO18에 하드웨어 PWM 100 kHz, 50 % -> Scope로 상승 시간(rise time) 관찰
 *        4) Ctrl+C로 끝내면 원래 구동 세기로 되돌린다.
 * 회로 : GPIO17 (물리 핀 11) -> 부하 저항(예: 1 kΩ, 330 Ω) -> GND,  Scope CH1(1+) = GPIO17
 *        GPIO18 (물리 핀 12) -> Scope CH2(2+)
 *        Scope 1-, 2- 와 AD2 GND -> Pi GND (물리 핀 14)
 * 빌드 : gcc -Wall -O2 -pthread -o pad_strength pad_strength.c -lpigpio -lrt
 * 실행 : sudo ./pad_strength 2      (2 mA)
 *        sudo ./pad_strength 16     (16 mA)
 *
 * 주의 : 구동 세기는 핀 하나가 아니라 GPIO0~27 전체에 함께 적용되고,
 *        프로그램이 끝나도 레지스터에 남는다. 그래서 끝날 때 원래 값으로 되돌린다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <pigpio.h>

#define PAD        0           /* pad 0 = GPIO0~27 */
#define LEVEL_GPIO 17          /* 물리 핀 11: 계속 High */
#define PWM_GPIO   18          /* 물리 핀 12: 하드웨어 PWM0 */
#define PWM_FREQ   100000      /* 100 kHz */
#define PWM_DUTY   500000      /* 50 % (0~1000000) */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(int argc, char *argv[])
{
    int want = (argc > 1) ? atoi(argv[1]) : 8;
    int orig, now;

    if (want < 2 || want > 16 || (want % 2) != 0) {
        fprintf(stderr, "사용법: sudo ./pad_strength <2|4|6|8|10|12|14|16>\n");
        return 1;
    }
    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    orig = gpioGetPad(PAD);
    gpioSetPad(PAD, (unsigned)want);
    now = gpioGetPad(PAD);
    printf("pad %d 구동 세기: 원래 %d mA -> 지금 %d mA\n", PAD, orig, now);

    gpioSetMode(LEVEL_GPIO, PI_OUTPUT);
    gpioWrite(LEVEL_GPIO, 1);
    gpioHardwarePWM(PWM_GPIO, PWM_FREQ, PWM_DUTY);
    printf("GPIO%d = High, GPIO%d = %d Hz PWM. 측정 후 Ctrl+C\n",
           LEVEL_GPIO, PWM_GPIO, PWM_FREQ);

    while (running)
        gpioDelay(100000);

    gpioHardwarePWM(PWM_GPIO, 0, 0);          /* PWM 끄기 */
    gpioSetMode(PWM_GPIO, PI_INPUT);
    gpioWrite(LEVEL_GPIO, 0);
    gpioSetMode(LEVEL_GPIO, PI_INPUT);
    gpioSetPad(PAD, (unsigned)orig);           /* 원래 구동 세기로 복구 */
    printf("\n구동 세기를 %d mA로 되돌리고 종료\n", gpioGetPad(PAD));
    gpioTerminate();
    return 0;
}
