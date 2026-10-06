/*
 * uart_loopback.c : 실습 12-1  UART 루프백(TX와 RX를 점퍼로 연결)으로 송수신 확인
 *
 * 회로 : GPIO14/TXD (물리 핀 8) <-- 점퍼선 --> GPIO15/RXD (물리 핀 10)
 * 준비 : 시리얼 콘솔을 끈다(raspi-config > Interface Options > Serial Port:
 *        login shell = No, serial hardware = Yes, 재부팅). 작업은 SSH로 한다.
 * 빌드 : gcc -Wall -O2 -pthread -o uart_loopback uart_loopback.c -lpigpio -lrt
 * 실행 : sudo ./uart_loopback                     115200 bps, 기본 문장 10회
 *        sudo ./uart_loopback 9600 "Hello UART"    보율과 문장을 지정
 *
 * 원본 : 부록 B의 serialTest_pigpio.c(0~255를 한 바이트씩 보내고 받기)를 바탕으로
 *        보율 인자, 문장 단위 송수신, 틀린 바이트 세기, 걸린 시간 측정을 더했다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <signal.h>
#include <pigpio.h>

#define ROUNDS      10
#define TIMEOUT_US  500000          /* 되돌아오기를 기다리는 최대 시간 0.5 s */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(int argc, char *argv[])
{
    char dev[] = "/dev/serial0";          /* serOpen의 인자는 char * (const 아님) */
    unsigned baud = (argc > 1) ? (unsigned)atoi(argv[1]) : 115200;
    const char *text = (argc > 2) ? argv[2] : "Hello, UART loopback!";
    char tx[128], rx[128];
    int h, len, got, n, i, round;
    int bad_bytes = 0, lost_bytes = 0;
    uint32_t t0, dt;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    h = serOpen(dev, baud, 0);
    if (h < 0) {
        fprintf(stderr, "serOpen(%s, %u) 실패 (%d): 보율이 표준값인지, "
                        "UART가 켜져 있는지 확인하라.\n", dev, baud, h);
        gpioTerminate();
        return 1;
    }

    printf("%s, %u bps 8N1. 비트 시간 %.2f us, 바이트(10비트) %.1f us\n",
           dev, baud, 1.0e6 / baud, 10.0e6 / baud);

    for (round = 1; round <= ROUNDS && running; round++) {
        len = snprintf(tx, sizeof(tx), "[%02d] %s\n", round, text);
        if (len >= (int)sizeof(tx))
            len = (int)sizeof(tx) - 1;

        while (serDataAvailable((unsigned)h) > 0)    /* 남아 있던 바이트 비우기 */
            serRead((unsigned)h, rx, sizeof(rx));

        t0 = gpioTick();
        serWrite((unsigned)h, tx, (unsigned)len);

        got = 0;                                     /* len 바이트가 올 때까지 모은다 */
        while (got < len && running) {
            n = serDataAvailable((unsigned)h);
            if (n > 0) {
                if (n > len - got)
                    n = len - got;
                n = serRead((unsigned)h, rx + got, (unsigned)n);
                if (n > 0)
                    got += n;
            }
            if ((uint32_t)(gpioTick() - t0) > TIMEOUT_US)
                break;
            gpioDelay(200);
        }
        dt = gpioTick() - t0;

        for (i = 0; i < got; i++)
            if (rx[i] != tx[i])
                bad_bytes++;
        lost_bytes += len - got;

        printf("보냄 %2d B, 받음 %2d B, %6u us (이론 %6.0f us) : %.*s",
               len, got, dt, len * 10.0e6 / baud,
               got, got > 0 ? rx : "");
        if (got == 0 || rx[got - 1] != '\n')
            printf("\n");
        gpioDelay(200000);
    }

    printf("결과: 틀린 바이트 %d, 잃어버린 바이트 %d\n", bad_bytes, lost_bytes);
    if (lost_bytes > 0)
        printf("받지 못한 바이트가 있다: TX-RX 점퍼, 시리얼 콘솔(getty)이 아직 붙어 있는지 확인하라.\n");

    serClose((unsigned)h);
    gpioTerminate();
    return 0;
}
