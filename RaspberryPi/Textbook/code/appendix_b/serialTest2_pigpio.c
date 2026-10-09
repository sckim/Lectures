/*
 * serialTest2_pigpio.c : 부록 B  3초마다 "Pong!"과 'A'를 보내고, 받은 문자는 바로 출력
 *
 * 회로 : Pi TXD GPIO14 (물리 핀 8)  -> 상대 장치 RX
 *        Pi RXD GPIO15 (물리 핀 10) <- 상대 장치 TX
 *        GND (물리 핀 6)            -- 상대 장치 GND        (상대도 3.3 V 논리여야 한다)
 *        상대 장치: USB-TTL 변환기 + PC 터미널(9600 bps), 또는 3.3 V 마이크로컨트롤러 보드
 * 준비 : serialTest_pigpio.c 와 같다 (시리얼 콘솔 끄기, UART 하드웨어 켜기)
 * 빌드 : gcc -Wall -pthread -o serialTest2_pigpio serialTest2_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./serialTest2_pigpio
 *
 * 원본 : wiringpi/serialTest2.c (Raspberry Pi Codes §4.5 두 번째 코드)
 *        setup()/loop() 구조는 그대로 두고
 *        serialPuts(fd, s)      -> serWrite(h, s, strlen(s))
 *        serialPutchar(fd, 65)  -> serWriteByte(h, 65)
 *        millis() - time >= 3000 -> (gpioTick() - last) >= 3000000  (uint32_t 뺄셈)
 *        원본의 전역 변수 time 은 표준 함수 time()과 이름이 같아 헷갈리므로 last_us 로 바꿨다.
 */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <pigpio.h>

static char device[] = "/dev/serial0";   /* 하드웨어 UART (GPIO14/15) */
/* USB 장치라면 "/dev/ttyACM0", "/dev/ttyUSB0" 등 (ls /dev/tty* 로 확인) */
static const unsigned baud = 9600;

static int h;                            /* serOpen 핸들 */
static uint32_t last_us;
static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static void setup(void)
{
    printf("Raspberry Startup!\n");
    fflush(stdout);

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        exit(1);
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    h = serOpen(device, baud, 0);
    if (h < 0) {
        fprintf(stderr, "Unable to open serial device %s (오류 %d)\n", device, h);
        gpioTerminate();
        exit(1);
    }
    last_us = gpioTick();
}

static void loop(void)
{
    char msg[] = "Pong!\n";
    int c;

    /* Pong every 3 seconds */
    if ((uint32_t)(gpioTick() - last_us) >= 3000000u) {
        printf("Sending: Pong!\n");
        serWrite(h, msg, strlen(msg));
        printf("Sending: A\n");
        serWriteByte(h, 65);
        last_us = gpioTick();
    }

    /* read signal */
    if (serDataAvailable(h) > 0) {
        c = serReadByte(h);
        if (c >= 0) {
            printf("Received: %c (ASCII: %d)\n", (c >= 32 && c < 127) ? c : '.', c);
            fflush(stdout);
        }
    }
    gpioDelay(1000);                     /* 원본은 바쁜 대기. 1 ms 쉬어 CPU 점유를 낮춘다 */
}

int main(void)
{
    setup();
    while (running)
        loop();

    serClose(h);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
