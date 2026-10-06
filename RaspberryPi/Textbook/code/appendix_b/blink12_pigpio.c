/*
 * blink12_pigpio.c : 부록 B  LED 시퀀서 (데이터 테이블로 패턴 정의) - 8-LED 바 판
 *
 * 회로 : 교재 표준 8-LED 바 LED0~LED7 (아래 leds[] 표의 8개 GPIO에 각각 330 Ω + LED -> GND)
 * 빌드 : gcc -Wall -pthread -o blink12_pigpio blink12_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./blink12_pigpio
 *
 * 원본 : wiringpi/blink12.c (Raspberry Pi Codes §4.1.4)
 *        원본은 LED 12개를 wPi 0~7, 그다음 11, 10, 13, 12 순서로 연결했다. 뒤의 네 개
 *        (wPi 10~13 = GPIO8·7·10·9)는 SPI0 핀이라 교재 표준 배선에서는 MCP3008이 쓴다
 *        (한 핀 = 한 역할). 그래서 이 판은 LED를 8-LED 바 8개로 줄이고, data[] 표도
 *        LED 번호 0~7로 다시 썼다. "다음 LED를 켜고 나서 이전 LED를 끈다"(두 개가
 *        겹쳐 켜지며 흐르는) 원본의 패턴과 "표(data) 따로, 실행 루프 따로" 구조는 같다.
 *        원본처럼 0~13 전부를 출력으로 만들지 않고, 실제로 쓰는 8개만 출력으로 설정한다.
 */
#include <stdio.h>
#include <signal.h>
#include <pigpio.h>

/* LED 번호 -> BCM 번호 (교재 표준 8-LED 바) */
/*  LED:                        0   1   2   3   4   5   6   7 */
/*  물리 핀:                   11  13  15  16  18  22  29  31 */
static const unsigned leds[] = {17, 27, 22, 23, 24, 25,  5,  6};
#define N_LEDS  (sizeof(leds) / sizeof(leds[0]))

/* (LED, On/Off, 지속시간[0.1초]) 세 개씩 묶음. 원본의 12칸 패턴을 8칸으로 줄였다. */
static const int data[] = {
     0, 1, 1,   1, 1, 1,
     0, 0, 0,   2, 1, 1,
     1, 0, 0,   3, 1, 1,
     2, 0, 0,   4, 1, 1,
     3, 0, 0,   5, 1, 1,
     4, 0, 0,   6, 1, 1,
     5, 0, 0,   7, 1, 1,
     6, 0, 1,   7, 0, 1,
     0, 0, 1,                   /* Extra delay */

    /* Back again */
     7, 1, 1,   6, 1, 1,
     7, 0, 0,   5, 1, 1,
     6, 0, 0,   4, 1, 1,
     5, 0, 0,   3, 1, 1,
     4, 0, 0,   2, 1, 1,
     3, 0, 0,   1, 1, 1,
     2, 0, 0,   0, 1, 1,
     1, 0, 1,   0, 0, 1,
     0, 0, 1,                   /* Extra delay */

     0, 9, 0,                   /* End marker */
};

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(void)
{
    unsigned i;
    int ptr = 0, l, s, d;

    printf("Raspberry Pi - LED Sequence (pigpio, 8-LED bar)\n");

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    for (i = 0; i < N_LEDS; i++) {
        gpioSetMode(leds[i], PI_OUTPUT);
        gpioWrite(leds[i], 0);
    }

    while (running) {
        l = data[ptr++];        /* LED (0~7) */
        s = data[ptr++];        /* State */
        d = data[ptr++];        /* Duration (0.1초 단위) */

        if (s == 9) {           /* 9 -> End Marker */
            ptr = 0;
            continue;
        }
        gpioWrite(leds[l], s);
        gpioDelay(d * 100000);  /* delay(d * 100) ms -> us */
    }

    for (i = 0; i < N_LEDS; i++) {
        gpioWrite(leds[i], 0);
        gpioSetMode(leds[i], PI_INPUT);
    }
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
