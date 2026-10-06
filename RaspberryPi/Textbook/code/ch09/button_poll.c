/*
 * button_poll.c : 실습 9-1(가)  폴링(polling) 방식으로 버튼 누른 횟수 세기
 *
 * 회로 : 버튼 한쪽 -> GPIO26 (물리 핀 37), 다른 쪽 -> GND (물리 핀 39), 내부 풀업
 *        LED : GPIO17 (물리 핀 11) -> 330 Ω -> LED -> GND (물리 핀 9)
 * 동작 : 정해진 간격마다 버튼을 읽고, 1 -> 0으로 바뀐 순간(눌림)을 센다.
 *        누를 때마다 LED를 반전한다.
 * 빌드 : gcc -Wall -pthread -o button_poll button_poll.c -lpigpio -lrt
 * 실행 : sudo ./button_poll [폴링간격_ms]
 *          sudo ./button_poll 10    10 ms마다 읽기(기본값)
 *          sudo ./button_poll 0     쉬지 않고 읽기(바쁜 대기) -> top으로 CPU 사용률 확인
 *          sudo ./button_poll 300   300 ms마다 읽기 -> 짧게 누르면 놓친다
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <pigpio.h>

#define LED_GPIO     17        /* 물리 핀 11 */
#define BUTTON_GPIO  26        /* 물리 핀 37 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(int argc, char *argv[])
{
    unsigned interval_ms = 10;
    unsigned long reads = 0;            /* gpioRead()를 부른 횟수 */
    unsigned presses = 0;               /* 눌림(1 -> 0) 횟수 */
    int level, last;
    uint32_t start_tick, elapsed_us;

    if (argc > 1)
        interval_ms = (unsigned)atoi(argv[1]);

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패: sudo로 실행했는지, "
                        "pigpiod가 떠 있지 않은지 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(LED_GPIO, PI_OUTPUT);
    gpioWrite(LED_GPIO, 0);
    gpioSetMode(BUTTON_GPIO, PI_INPUT);
    gpioSetPullUpDown(BUTTON_GPIO, PI_PUD_UP);   /* 뗌 = 1, 눌림 = 0 */

    printf("폴링 간격 %u ms (0이면 바쁜 대기). 버튼을 눌러 보라. Ctrl+C로 종료\n",
           interval_ms);

    last = gpioRead(BUTTON_GPIO);
    start_tick = gpioTick();

    while (running) {
        level = gpioRead(BUTTON_GPIO);
        reads++;
        if (last == 1 && level == 0) {           /* 하강 에지 = 눌린 순간 */
            presses++;
            gpioWrite(LED_GPIO, presses & 1);    /* 누를 때마다 LED 반전 */
            printf("눌림 %u회 (지금까지 읽은 횟수 %lu)\n", presses, reads);
        }
        last = level;
        if (interval_ms > 0)
            gpioDelay(interval_ms * 1000);       /* 쉬는 동안 CPU를 양보한다 */
    }

    elapsed_us = gpioTick() - start_tick;        /* uint32_t 뺄셈: 랩어라운드 안전 */
    printf("\n%.1f초 동안 %lu번 읽음 (초당 약 %.0f번), 눌림 %u회\n",
           elapsed_us / 1e6, reads, reads / (elapsed_us / 1e6), presses);

    gpioWrite(LED_GPIO, 0);
    gpioSetMode(LED_GPIO, PI_INPUT);
    gpioTerminate();
    return 0;
}
