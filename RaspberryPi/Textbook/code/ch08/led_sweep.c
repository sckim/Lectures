/*
 * led_sweep.c : 실습 8-4  여러 개의 LED를 차례로 켜고 끄기
 *
 * 회로 : 아래 배열의 8개 GPIO에 각각 330 Ω + LED -> GND
 *        (교재 표준 배선의 LED0~LED7 = GPIO17, 27, 22, 23, 24, 25, 5, 6. 8장 8.2.4절)
 * 빌드 : gcc -Wall -pthread -o led_sweep led_sweep.c -lpigpio -lrt
 * 실행 : sudo ./led_sweep [지연_ms]        예) sudo ./led_sweep 100
 *
 * 원본 : WiringPi-master/examples/blink_sweep.c (setup()/loop() 구조 유지)
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <pigpio.h>

/*                       LED 번호:  0   1   2   3   4   5   6   7 */
/*                       물리 핀:  11  13  15  16  18  22  29  31 */
static const unsigned leds[] = {   17, 27, 22, 23, 24, 25,  5,  6 };
#define N_LEDS  (sizeof(leds) / sizeof(leds[0]))

static unsigned delay_us = 100000;           /* 기본 100 ms */
static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static void setup(void)
{
    for (unsigned i = 0; i < N_LEDS; i++) {
        gpioSetMode(leds[i], PI_OUTPUT);
        gpioWrite(leds[i], 0);
    }
}

static void loop(void)
{
    for (unsigned i = 0; i < N_LEDS && running; i++) {
        printf("GPIO%-2u = High\n", leds[i]);
        gpioWrite(leds[i], 1);
        gpioDelay(delay_us);
        printf("GPIO%-2u = Low\n", leds[i]);
        gpioWrite(leds[i], 0);
    }
}

int main(int argc, char *argv[])
{
    if (argc > 1)
        delay_us = (unsigned)atoi(argv[1]) * 1000u;   /* ms -> us */

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    printf("Raspberry Pi GPIO Sweep (%u ms, Ctrl+C로 종료)\n", delay_us / 1000);
    setup();
    while (running)
        loop();

    for (unsigned i = 0; i < N_LEDS; i++) {     /* 모두 끄고 입력으로 되돌림 */
        gpioWrite(leds[i], 0);
        gpioSetMode(leds[i], PI_INPUT);
    }
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
