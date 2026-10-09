/*
 * pullupdown_pigpio.c : 부록 B  아무것도 연결하지 않은 입력 핀의 내부 풀업/풀다운을 번갈아 켜고 읽기
 *
 * 회로 : BTN0 = GPIO26 (물리 핀 37) -- 버튼 -- GND (교재 표준 배선. 버튼을 떼고 있으면
 *        핀은 아무 데도 연결되지 않은 것과 같다). 버튼이 없어도 된다.
 *        원본은 wPi 0 = GPIO17을 썼지만, 교재 표준 배선에서 GPIO17은 LED0이라
 *        LED·저항이 핀을 GND 쪽으로 당겨 풀업 결과가 달라진다. 그래서 입력 핀 BTN0으로 옮겼다.
 * 빌드 : gcc -Wall -pthread -o pullupdown_pigpio pullupdown_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./pullupdown_pigpio
 * 결과 : 1초마다 "PUD_UP -> 1", "PUD_DOWN -> 0"이 번갈아 나오면 정상
 *        버튼을 누른 채로 두면 GND에 직접 연결되므로 둘 다 0이 나온다.
 *
 * 원본 : wiringpi/pullupdown.c (Raspberry Pi Codes §4.2.1)
 *        pullUpDnControl(pin, PUD_UP/PUD_DOWN) -> gpioSetPullUpDown(gpio, PI_PUD_UP/PI_PUD_DOWN)
 *        digitalRead -> gpioRead
 *        (강의 자료의 gpioSetPullUpDn은 존재하지 않는 이름이다. 정확한 이름은 gpioSetPullUpDown)
 */
#include <stdio.h>
#include <signal.h>
#include <pigpio.h>

#define INPUT_GPIO  26                   /* BTN0, 물리 핀 37 (원본 wPi 0 = GPIO17) */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(void)
{
    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(INPUT_GPIO, PI_INPUT);

    while (running) {
        gpioSetPullUpDown(INPUT_GPIO, PI_PUD_UP);
        gpioDelay(1000);                 /* 1 ms: 풀업이 핀 전압을 끌어올릴 시간 */
        printf("PUD_UP   -> gpioRead(%d) : %d\n", INPUT_GPIO, gpioRead(INPUT_GPIO));
        gpioDelay(1000000);

        gpioSetPullUpDown(INPUT_GPIO, PI_PUD_DOWN);
        gpioDelay(1000);
        printf("PUD_DOWN -> gpioRead(%d) : %d\n", INPUT_GPIO, gpioRead(INPUT_GPIO));
        gpioDelay(1000000);
    }

    gpioSetPullUpDown(INPUT_GPIO, PI_PUD_UP);    /* BTN0의 표준 설정(풀업)으로 되돌림 */
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
