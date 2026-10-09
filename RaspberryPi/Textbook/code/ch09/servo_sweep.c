/*
 * servo_sweep.c : 실습 9-5  서보 펄스(gpioServo)로 각도 제어
 *
 * 회로 : 서보 신호선(주황/노랑) -> GPIO13 (물리 핀 33)
 *        서보 전원(빨강)        -> 별도 5 V 전원의 + (소형 서보 1개 시험이면 물리 핀 2도 가능)
 *        서보 GND(갈색/검정)    -> 별도 전원의 -, 그리고 Pi GND (물리 핀 34)  ※ GND 공통 필수
 * 동작 : 인자 없음 : 0도 -> 180도 -> 0도를 10도씩 왕복
 *        -i        : 키보드로 각도(0~180)를 입력받아 이동, q 또는 Ctrl+C로 종료
 * 빌드 : gcc -Wall -pthread -o servo_sweep servo_sweep.c -lpigpio -lrt
 * 실행 : sudo ./servo_sweep
 *        sudo ./servo_sweep -i
 *
 * 원본 : Raspberry Pi Codes §7.3.5 (GPIO13, 1500/500/2500 us),
 *        Linux 백서 PIGIO 탭 (각도 -> 500 + angle*2000/180)
 *        양 끝(500/2500 us)은 서보를 무리하게 밀 수 있어 안전 범위로 줄였다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <pigpio.h>

#define SERVO_GPIO    13
#define SERVO_MIN_US  1000     /* 0도에 대응. 내 서보에서 확인 후 넓힌다(최소 500) */
#define SERVO_MAX_US  2000     /* 180도에 대응. 확인 후 넓힌다(최대 2500) */
#define STEP_DEG      10
#define STEP_DELAY_US 200000   /* 서보가 움직일 시간 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* 각도(0~180) -> 펄스 폭(us). 범위를 벗어나면 잘라 낸다. */
static unsigned angle_to_us(int angle)
{
    if (angle < 0)
        angle = 0;
    if (angle > 180)
        angle = 180;
    return SERVO_MIN_US + (unsigned)angle * (SERVO_MAX_US - SERVO_MIN_US) / 180;
}

static void move_to(int angle)
{
    unsigned us = angle_to_us(angle);

    gpioServo(SERVO_GPIO, us);                   /* 50 Hz로 us 폭의 펄스를 계속 낸다 */
    printf("각도 %3d도 -> 펄스 %4u us (확인: %d us)\n",
           angle, us, gpioGetServoPulsewidth(SERVO_GPIO));
}

static void sweep(void)
{
    while (running) {
        for (int a = 0; a <= 180 && running; a += STEP_DEG) {
            move_to(a);
            gpioDelay(STEP_DELAY_US);
        }
        for (int a = 180; a >= 0 && running; a -= STEP_DEG) {
            move_to(a);
            gpioDelay(STEP_DELAY_US);
        }
    }
}

static void interactive(void)
{
    char line[32];

    while (running) {
        printf("각도(0~180, q=종료)> ");
        fflush(stdout);
        if (fgets(line, sizeof(line), stdin) == NULL)   /* Ctrl+C면 NULL이 온다 */
            break;
        if (line[0] == 'q')
            break;
        move_to(atoi(line));
    }
}

int main(int argc, char *argv[])
{
    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패: sudo로 실행했는지, "
                        "pigpiod가 떠 있지 않은지 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    move_to(90);                                 /* 먼저 가운데(안전한 위치)로 */
    gpioDelay(500000);

    if (argc > 1 && argv[1][0] == '-' && argv[1][1] == 'i')
        interactive();
    else
        sweep();

    move_to(90);                                 /* 가운데로 돌려놓고 */
    gpioDelay(500000);
    gpioServo(SERVO_GPIO, 0);                    /* 0 = 펄스 끔 (서보 힘 풀림) */
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
