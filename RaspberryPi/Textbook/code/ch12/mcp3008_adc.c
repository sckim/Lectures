/*
 * mcp3008_adc.c : 실습 12-5  SPI ADC(MCP3008)로 가변저항 전압 읽기 (+ LED 밝기 조절)
 *
 * 회로 : MCP3008  VDD(16), VREF(15) -> 3.3 V (물리 핀 17)
 *                 AGND(14), DGND(9) -> GND (물리 핀 20)
 *                 CLK(13)  <- GPIO11/SCLK (물리 핀 23)
 *                 DOUT(12) -> GPIO9/MISO  (물리 핀 21)
 *                 DIN(11)  <- GPIO10/MOSI (물리 핀 19)
 *                 CS(10)   <- GPIO8/CE0   (물리 핀 24)
 *                 CH0(1)   <- 가변저항 가운데 다리 (양 끝은 3.3 V와 GND)
 *        (선택) LED : GPIO18 (물리 핀 12) -> 330 Ω -> LED -> GND  (표준 핀 계획의 PWM 출력 핀)
 * 준비 : pigpio의 spiOpen은 SPI0 레지스터를 직접 다루므로 dtparam=spi=on이 필요 없다.
 *        커널 spidev 프로그램(mcp3008_spidev 등)과 동시에 실행하지 않는다.
 * 빌드 : gcc -Wall -O2 -pthread -o mcp3008_adc mcp3008_adc.c -lpigpio -lrt
 * 실행 : sudo ./mcp3008_adc            CH0을 0.2초마다 출력
 *        sudo ./mcp3008_adc 1          CH1
 *        sudo ./mcp3008_adc 0 led      CH0 값으로 GPIO18 LED 밝기(PWM) 조절 (9장 참고)
 *
 * 원본 : Raspberry Pi Codes 6.3 (Python spidev MCP3008)을 pigpio C로 옮겼다.
 *        전압 환산은 데이터시트대로 VREF/1024를 쓴다 (원본은 /1023).
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <pigpio.h>

#define SPI_CHAN   0               /* CE0 */
#define SPI_BAUD   1000000         /* 1 MHz: 3.3 V에서 데이터시트 한계(2.7 V에서 1.35 MHz) 안쪽 */
#define VREF       3.3
#define LED_GPIO   18              /* 물리 핀 12, AD2 DIO1 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* 단일 입력(single-ended) 채널 ch(0~7)를 읽어 0~1023을 돌려준다. 실패하면 -1. */
static int mcp3008_read(int h, int ch)
{
    char tx[3], rx[3];

    tx[0] = 0x01;                          /* 0000 0001 : 마지막 1이 시작 비트 */
    tx[1] = (char)(0x80 | (ch << 4));      /* SGL/DIFF=1, D2 D1 D0 = 채널, 나머지 0 */
    tx[2] = 0x00;                          /* 결과를 밀어내기 위한 빈 바이트 */
    if (spiXfer((unsigned)h, tx, rx, 3) != 3)
        return -1;
    /* rx[1]의 하위 2비트 = B9 B8, rx[2] = B7~B0 */
    return (((unsigned char)rx[1] & 0x03) << 8) | (unsigned char)rx[2];
}

int main(int argc, char *argv[])
{
    int ch = (argc > 1) ? atoi(argv[1]) & 7 : 0;
    int use_led = (argc > 2 && strcmp(argv[2], "led") == 0);
    int h, value, i, bar;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    h = spiOpen(SPI_CHAN, SPI_BAUD, 0);    /* flags 0 = 모드 0, CE active low */
    if (h < 0) {
        fprintf(stderr, "spiOpen 실패: %d\n", h);
        gpioTerminate();
        return 1;
    }

    if (use_led) {
        gpioSetMode(LED_GPIO, PI_OUTPUT);
        gpioSetPWMrange(LED_GPIO, 1023);   /* 듀티 범위를 ADC 범위에 맞춘다 */
    }

    printf("MCP3008 CH%d, SPI0 CE0 %d Hz 모드 0 (Ctrl+C로 종료)\n", ch, SPI_BAUD);
    while (running) {
        value = mcp3008_read(h, ch);
        if (value < 0) {
            fprintf(stderr, "spiXfer 실패\n");
            break;
        }
        bar = value * 40 / 1024;
        printf("\rCH%d = %4d  %.3f V  |", ch, value, value * VREF / 1024.0);
        for (i = 0; i < 40; i++)
            putchar(i < bar ? '#' : ' ');
        putchar('|');
        fflush(stdout);

        if (use_led)
            gpioPWM(LED_GPIO, (unsigned)value);
        gpioDelay(200000);
    }

    if (use_led) {
        gpioPWM(LED_GPIO, 0);
        gpioSetMode(LED_GPIO, PI_INPUT);
    }
    spiClose((unsigned)h);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
