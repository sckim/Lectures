/*
 * uart_cmd.c : 실습 12-2  PC 터미널에서 보낸 문자 명령으로 LED를 켜고 끄기
 *
 * 회로 : USB-TTL 어댑터(3.3 V)  GND -> GND (물리 핀 6)
 *                               RXD -> GPIO14/TXD (물리 핀 8)
 *                               TXD -> GPIO15/RXD (물리 핀 10)
 *        LED : GPIO17 (물리 핀 11) -> 330 Ω -> LED -> GND (8장과 같다)
 * 준비 : 시리얼 콘솔을 끈다(raspi-config > Interface Options > Serial Port:
 *        login shell = No, serial hardware = Yes, 재부팅). Pi 작업은 SSH로 한다.
 *        PC 터미널(PuTTY 등)은 3장과 같은 COM 포트, 115200 8N1, 흐름 제어 None.
 * 빌드 : gcc -Wall -O2 -pthread -o uart_cmd uart_cmd.c -lpigpio -lrt
 * 실행 : sudo ./uart_cmd            (115200 bps)
 *        sudo ./uart_cmd 9600       (PC 터미널도 9600으로 맞춘다)
 *
 * 규약 : 한 줄 = 명령 하나. 줄 끝은 CR, LF, CRLF 모두 받는다. 대소문자 무시.
 *        LED ON | LED OFF | STATUS | HELP  ->  응답 "OK ..." 또는 "ERR ..."
 *        받은 글자를 그대로 되돌려 보내므로(에코) PC 화면에 입력이 보인다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <signal.h>
#include <pigpio.h>

#define LED_GPIO  17               /* 물리 핀 11 */
#define LINE_MAX  32

static volatile sig_atomic_t running = 1;
static int h = -1;                 /* 시리얼 핸들 */

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* 문자열 한 줄을 PC로 보낸다. 터미널 줄바꿈은 CR+LF이다. */
static void reply(const char *s)
{
    char buf[64];
    int n = snprintf(buf, sizeof(buf), "%s\r\n", s);

    serWrite((unsigned)h, buf, (unsigned)n);
    printf("  -> %s\n", s);
}

/* 완성된 한 줄(명령)을 해석하고 실행한다. */
static void handle_line(char *line)
{
    int i;

    for (i = 0; line[i]; i++)                    /* 대문자로 통일 */
        line[i] = (char)toupper((unsigned char)line[i]);
    printf("받은 명령: \"%s\"\n", line);

    if (strcmp(line, "LED ON") == 0) {
        gpioWrite(LED_GPIO, 1);
        reply("OK LED=1");
    } else if (strcmp(line, "LED OFF") == 0) {
        gpioWrite(LED_GPIO, 0);
        reply("OK LED=0");
    } else if (strcmp(line, "STATUS") == 0) {
        reply(gpioRead(LED_GPIO) ? "OK LED=1" : "OK LED=0");
    } else if (strcmp(line, "HELP") == 0) {
        reply("OK commands: LED ON, LED OFF, STATUS, HELP");
    } else {
        reply("ERR unknown command (try HELP)");
    }
}

int main(int argc, char *argv[])
{
    char dev[] = "/dev/serial0";
    unsigned baud = (argc > 1) ? (unsigned)atoi(argv[1]) : 115200;
    char line[LINE_MAX + 1];
    char echo[2];
    int len = 0, c;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(LED_GPIO, PI_OUTPUT);
    gpioWrite(LED_GPIO, 0);

    h = serOpen(dev, baud, 0);
    if (h < 0) {
        fprintf(stderr, "serOpen(%s, %u) 실패 (%d)\n", dev, baud, h);
        gpioTerminate();
        return 1;
    }

    printf("%s %u bps에서 명령을 기다린다 (Ctrl+C로 종료)\n", dev, baud);
    reply("READY - type HELP");

    while (running) {
        c = serReadByte((unsigned)h);        /* 데이터가 없으면 바로 음수 */
        if (c < 0) {
            gpioDelay(2000);                 /* 2 ms 쉬고 다시 확인 */
            continue;
        }

        if (c == '\r' || c == '\n') {        /* 줄 끝: CR, LF, CRLF 모두 처리 */
            serWrite((unsigned)h, "\r\n", 2);
            if (len > 0) {                   /* CRLF의 두 번째 글자는 빈 줄 -> 무시 */
                line[len] = '\0';
                handle_line(line);
                len = 0;
            }
        } else if (c == 0x08 || c == 0x7F) { /* Backspace / Delete */
            if (len > 0) {
                len--;
                serWrite((unsigned)h, "\b \b", 3);
            }
        } else if (c >= 0x20 && c < 0x7F) {  /* 출력 가능한 글자만 모은다 */
            if (len < LINE_MAX) {
                line[len++] = (char)c;
                echo[0] = (char)c;
                serWrite((unsigned)h, echo, 1);   /* 에코 */
            }
        }
    }

    reply("BYE");
    gpioWrite(LED_GPIO, 0);
    gpioSetMode(LED_GPIO, PI_INPUT);
    serClose((unsigned)h);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
