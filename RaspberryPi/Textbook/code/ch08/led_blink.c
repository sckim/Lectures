/*
 * led_blink.c : 실습 8-2  pigpio C 라이브러리로 LED 점멸
 *
 * 회로 : GPIO17 (물리 핀 11) -> 330 Ω -> LED(애노드→캐소드) -> GND (물리 핀 9)
 * 빌드 : gcc -Wall -pthread -o led_blink led_blink.c -lpigpio -lrt
 * 실행 : sudo ./led_blink      (pigpiod 데몬이 실행 중이면 먼저 멈춘다)
 *
 * 원본 : WiringPi/led_onoff.c, Pigpio/pigpio_demo1.c 를 pigpio로 옮기고
 *        Ctrl+C 종료 처리를 추가하였다.
 */
#include <stdio.h>
#include <signal.h>
#include <pigpio.h>

#define LED_GPIO   17          /* BCM 번호. 물리 핀 11 */
#define HALF_US    500000      /* 반주기 500 ms (마이크로초 단위) */

static volatile sig_atomic_t running = 1;

/* pigpio가 SIGINT(Ctrl+C)를 받으면 이 함수를 불러 준다. */
static void on_signal(int signum)
{
    (void)signum;
    running = 0;               /* 플래그만 바꾸고 정리는 main에서 한다 */
}

int main(void)
{
    if (gpioInitialise() < 0) {            /* /dev/mem 직접 접근 시작 */
        fprintf(stderr, "pigpio 초기화 실패: sudo로 실행했는지, "
                        "pigpiod가 떠 있지 않은지 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);  /* gpioInitialise() 뒤에 등록 */

    gpioSetMode(LED_GPIO, PI_OUTPUT);
    printf("GPIO%d LED 점멸 시작 (Ctrl+C로 종료)\n", LED_GPIO);

    while (running) {
        gpioWrite(LED_GPIO, 1);
        printf("LED on\n");
        gpioDelay(HALF_US);
        gpioWrite(LED_GPIO, 0);
        printf("LED off\n");
        gpioDelay(HALF_US);
    }

    gpioWrite(LED_GPIO, 0);    /* 끄고 나간다 */
    gpioSetMode(LED_GPIO, PI_INPUT);
    gpioTerminate();           /* DMA 채널·메모리·스레드 정리 */
    printf("\n정상 종료\n");
    return 0;
}
