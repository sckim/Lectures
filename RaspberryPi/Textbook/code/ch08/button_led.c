/*
 * button_led.c : 실습 8-3  버튼 입력(내부 풀업)을 읽어 LED에 그대로 반영
 *
 * 회로 : 버튼 한쪽 -> GPIO26 (물리 핀 37), 다른 쪽 -> GND (물리 핀 39)
 *        LED는 실습 8-2와 같다 (GPIO17, 물리 핀 11)
 * 동작 : 내부 풀업 사용 -> 버튼을 떼면 1, 누르면 0 (active-low)
 *        누르면 LED가 켜진다.
 * 빌드 : gcc -Wall -pthread -o button_led button_led.c -lpigpio -lrt
 * 실행 : sudo ./button_led
 *
 * 원본 : WiringPi-master/examples/gpio_read.c (풀다운 + 매 루프 출력)를
 *        pigpio로 옮기고, 풀업 방식과 "바뀔 때만 출력"으로 고쳤다.
 */
#include <stdio.h>
#include <signal.h>
#include <pigpio.h>

#define LED_GPIO     17        /* 물리 핀 11 */
#define BUTTON_GPIO  26        /* 물리 핀 37 */
#define POLL_US      5000      /* 5 ms마다 한 번 읽는다(폴링 주기) */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(void)
{
    int level, last = -1;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(LED_GPIO, PI_OUTPUT);
    gpioWrite(LED_GPIO, 0);

    gpioSetMode(BUTTON_GPIO, PI_INPUT);
    gpioSetPullUpDown(BUTTON_GPIO, PI_PUD_UP);   /* 내부 풀업 켜기 */

    printf("버튼(GPIO%d)을 눌러 보라. Ctrl+C로 종료\n", BUTTON_GPIO);

    while (running) {
        level = gpioRead(BUTTON_GPIO);
        if (level != last) {                     /* 바뀔 때만 처리 */
            printf("GPIO%d = %d (%s)\n", BUTTON_GPIO, level,
                   level == 0 ? "눌림" : "뗌");
            gpioWrite(LED_GPIO, !level);         /* active-low 이므로 반전 */
            last = level;
        }
        gpioDelay(POLL_US);                      /* CPU 100% 점유 방지 */
    }

    gpioWrite(LED_GPIO, 0);
    gpioSetMode(LED_GPIO, PI_INPUT);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
