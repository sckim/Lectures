/*
 * blink8_pigpio.c : 부록 B  LED 8개를 차례로 켜서 모두 켠 뒤, 차례로 끈다
 *
 * 회로 : 교재 표준 8-LED 바 LED0~LED7 (아래 표의 8개 GPIO에 각각 330 Ω + LED -> GND)
 * 빌드 : gcc -Wall -pthread -o blink8_pigpio blink8_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./blink8_pigpio
 *
 * 원본 : wiringpi/blink8.c (Raspberry Pi Codes §4.1.2)
 *        WiringPi는 pinMode(i, OUTPUT)처럼 0~7을 연속으로 돌렸지만, BCM 번호는
 *        연속이 아니므로 핀 번호 배열로 바꾸었다.
 * 핀   : 원본 wPi 0~7 = BCM 17,18,27,22,23,24,25,4 를 그대로 옮기지 않고, 원본의
 *        i번 LED를 교재 표준 LED i (BCM 17,27,22,23,24,25,5,6)로 옮겼다.
 *        GPIO18은 PWM·부저, GPIO4는 DHT11/RHT03 자리이기 때문이다(부록 C.4).
 */
#include <stdio.h>
#include <signal.h>
#include <pigpio.h>

/*                         LED:   0   1   2   3   4   5   6   7 */
/*                     물리 핀:  11  13  15  16  18  22  29  31 */
static const unsigned leds[] = { 17, 27, 22, 23, 24, 25,  5,  6 };
#define N_LEDS   (sizeof(leds) / sizeof(leds[0]))
#define STEP_US  100000                  /* delay(100) -> 100 ms */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(void)
{
    unsigned i;

    printf("Raspberry Pi - 8-LED Sequencer (pigpio)\n");
    printf("=======================================\n\n");

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    for (i = 0; i < N_LEDS; i++)                 /* pinMode(i, OUTPUT) */
        gpioSetMode(leds[i], PI_OUTPUT);

    while (running) {
        for (i = 0; i < N_LEDS && running; i++) {   /* 하나씩 켜서 모두 켠다 */
            gpioWrite(leds[i], 1);
            gpioDelay(STEP_US);
        }
        for (i = 0; i < N_LEDS && running; i++) {   /* 하나씩 끈다 */
            gpioWrite(leds[i], 0);
            gpioDelay(STEP_US);
        }
    }

    for (i = 0; i < N_LEDS; i++) {               /* 모두 끄고 입력으로 되돌림 */
        gpioWrite(leds[i], 0);
        gpioSetMode(leds[i], PI_INPUT);
    }
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
