/*
 * spi_send.c : 실습 10-7  SPI0로 0x11, 0x20 두 바이트를 보내며 모드(CPOL/CPHA)를 비교
 *
 * 회로 : GPIO8/CE0   (물리 핀 24) -> AD2 DIO 10 (Select)
 *        GPIO11/SCLK (물리 핀 23) -> AD2 DIO 11 (Clock)
 *        GPIO10/MOSI (물리 핀 19) -> AD2 DIO 12 (MOSI)
 *        GPIO9/MISO  (물리 핀 21) -> AD2 DIO 13 (MISO)
 *        GND (물리 핀 20)          -> AD2 GND
 *        (선택) MOSI와 MISO를 점퍼로 이으면 루프백: 보낸 값이 그대로 돌아온다.
 * 빌드 : gcc -Wall -O2 -pthread -o spi_send spi_send.c -lpigpio -lrt
 * 실행 : sudo ./spi_send 0          모드 0 (CPOL=0, CPHA=0), 1 MHz
 *        sudo ./spi_send 1          모드 1 (CPOL=0, CPHA=1)
 *        sudo ./spi_send 3 100000   모드 3, 100 kHz
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <pigpio.h>

#define SPI_CHAN 0             /* CE0 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(int argc, char *argv[])
{
    unsigned mode = (argc > 1) ? (unsigned)atoi(argv[1]) & 3u : 0;
    unsigned baud = (argc > 2) ? (unsigned)atoi(argv[2]) : 1000000;
    char tx[2] = { 0x11, 0x20 };
    char rx[2] = { 0, 0 };
    int h;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    /* spiFlags 하위 2비트(mm)가 SPI 모드이다. 나머지는 기본값(CE active low, MSB first). */
    h = spiOpen(SPI_CHAN, baud, mode);
    if (h < 0) {
        fprintf(stderr, "spiOpen 실패: %d\n", h);
        gpioTerminate();
        return 1;
    }
    printf("SPI0 CE0, 모드 %u (CPOL=%u, CPHA=%u), %u Hz. 0x11 0x20 을 100 ms마다 전송\n",
           mode, mode >> 1, mode & 1, baud);

    while (running) {
        spiXfer((unsigned)h, tx, rx, 2);     /* 보내면서 동시에 받는다(전이중) */
        printf("\r  TX %02X %02X  RX %02X %02X", tx[0], tx[1],
               (unsigned char)rx[0], (unsigned char)rx[1]);
        fflush(stdout);
        gpioDelay(100000);
    }

    spiClose((unsigned)h);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
