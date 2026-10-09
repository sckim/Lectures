/*
 * led_blink_if2.c : 실습 8-5  pigpiod 데몬에 접속하는 클라이언트로 LED 점멸
 *
 * 회로 : 실습 8-2와 같다 (GPIO17, 물리 핀 11)
 * 준비 : sudo systemctl start pigpiod     (데몬이 반드시 실행 중이어야 한다)
 * 빌드 : gcc -Wall -pthread -o led_blink_if2 led_blink_if2.c -lpigpiod_if2 -lrt
 * 실행 : ./led_blink_if2                 (sudo가 필요 없다)
 *        ./led_blink_if2 192.168.0.xx    (다른 Pi의 데몬에 원격 접속)
 *
 * 함수 이름이 다르다:  gpioInitialise -> pigpio_start,  gpioSetMode -> set_mode,
 *                     gpioWrite -> gpio_write,         gpioTerminate -> pigpio_stop
 * 모든 함수의 첫 인자 pi는 "어느 데몬에 보낼 것인가"를 뜻한다.
 */
#include <stdio.h>
#include <signal.h>
#include <pigpiod_if2.h>

#define LED_GPIO  17

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(int argc, char *argv[])
{
    const char *host = (argc > 1) ? argv[1] : NULL;   /* NULL이면 localhost */
    int pi;

    pi = pigpio_start(host, NULL);                    /* NULL 포트 = 8888 */
    if (pi < 0) {
        fprintf(stderr, "pigpiod에 접속할 수 없다: %s\n", pigpio_error(pi));
        fprintf(stderr, "sudo systemctl start pigpiod 로 데몬을 먼저 켜라.\n");
        return 1;
    }
    /* 데몬 클라이언트는 pigpio의 시그널 처리기가 없으므로 직접 등록한다. */
    signal(SIGINT, on_signal);

    set_mode(pi, LED_GPIO, PI_OUTPUT);
    printf("데몬(%s)을 통해 GPIO%d 점멸 (Ctrl+C로 종료)\n",
           host ? host : "localhost", LED_GPIO);

    while (running) {
        gpio_write(pi, LED_GPIO, 1);
        time_sleep(0.5);
        gpio_write(pi, LED_GPIO, 0);
        time_sleep(0.5);
    }

    gpio_write(pi, LED_GPIO, 0);
    set_mode(pi, LED_GPIO, PI_INPUT);
    pigpio_stop(pi);                                  /* 연결만 끊는다. 데몬은 계속 돈다 */
    printf("\n정상 종료\n");
    return 0;
}
