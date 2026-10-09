/*
 * uart_send.c : 실습 10-5  UART TX(GPIO14)로 한 바이트를 주기적으로 보내 파형을 잰다
 *
 * 회로 : GPIO14/TXD (물리 핀 8) -> AD2 DIO 8 (워크스페이스의 "UART TxD")
 *        GND (물리 핀 6)        -> AD2 GND
 * 준비 : 시리얼 콘솔을 끈다(raspi-config > Interface Options > Serial Port:
 *        login shell = No, serial hardware = Yes, 재부팅). 작업은 SSH로 한다.
 * 빌드 : gcc -Wall -O2 -pthread -o uart_send uart_send.c -lpigpio -lrt
 * 실행 : sudo ./uart_send 9600 a         'a'(0x61)를 100 ms마다 보낸다
 *        sudo ./uart_send 115200 0x55    0x55를 보낸다(0과 1이 번갈아 나오는 바이트)
 *        Ctrl+C로 끝낸다. 형식은 8N1(데이터 8비트, 패리티 없음, 정지 비트 1).
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <pigpio.h>

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(int argc, char *argv[])
{
    char dev[] = "/dev/serial0";
    unsigned baud = (argc > 1) ? (unsigned)atoi(argv[1]) : 9600;
    unsigned char byte = 'a';
    int h, i;

    if (argc > 2)                       /* "a" 같은 글자 또는 "0x55" 같은 숫자 */
        byte = (argv[2][0] == '0' && argv[2][1] == 'x')
                   ? (unsigned char)strtol(argv[2], NULL, 16)
                   : (unsigned char)argv[2][0];

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    h = serOpen(dev, baud, 0);
    if (h < 0) {
        fprintf(stderr, "serOpen(%s, %u) 실패: 콘솔이 쓰고 있지 않은지, "
                        "UART가 켜져 있는지 확인하라.\n", dev, baud);
        gpioTerminate();
        return 1;
    }

    printf("%s %u bps로 0x%02X('%c')를 100 ms마다 전송 (Ctrl+C로 종료)\n",
           dev, baud, byte, (byte >= 0x20 && byte < 0x7f) ? byte : '.');
    printf("비트 시간 = 1/%u = %.2f us, 한 프레임(10비트) = %.2f us\n",
           baud, 1.0e6 / baud, 10.0e6 / baud);
    printf("LSB부터 보내므로 선 위의 데이터 비트 순서: ");
    for (i = 0; i < 8; i++)
        printf("%d", (byte >> i) & 1);
    printf("\n");

    while (running) {
        serWriteByte((unsigned)h, byte);
        gpioDelay(100000);
    }

    serClose((unsigned)h);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
