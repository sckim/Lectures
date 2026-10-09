/*
 * blink_thread2_pigpio.c : 부록 B  스레드 두 개가 서로 다른 주기로 LED 두 개를 점멸
 *
 * 회로 : LED0 = GPIO17 (물리 핀 11), LED1 = GPIO27 (물리 핀 13), 각각 330 Ω + LED -> GND
 *        (교재 표준 8-LED 바의 LED0·LED1. 원본의 wPi 1 = GPIO18은 PWM·부저 자리라 옮겼다)
 * 빌드 : gcc -Wall -pthread -o blink_thread2_pigpio blink_thread2_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./blink_thread2_pigpio
 *
 * 원본 : wiringpi/blink_thread2.c (Raspberry Pi Codes §4.1.5 두 번째 코드)
 *        두 스레드 함수의 내용이 핀과 주기만 다르므로, 함수 하나에 인자로
 *        "핀과 반주기"를 넘기는 구조로 바꾸었다. 인자는 main이 끝날 때까지
 *        살아 있는 static 배열의 원소 주소를 넘긴다(지역 변수 주소를 넘기면
 *        스레드가 읽기 전에 값이 바뀌거나 사라질 수 있다).
 *        참고: pigpio의 gpioStartThread(f, userdata)도 같은 방식으로 인자를 넘긴다.
 *
 * 관찰 : 10 ms / 20 ms 반주기이므로 눈에는 계속 켜져 있거나 떨리는 것처럼 보인다.
 *        오실로스코프나 로직 분석기로 50 Hz와 25 Hz 파형을 확인해 보라(10장).
 */
#include <stdio.h>
#include <signal.h>
#include <pthread.h>
#include <pigpio.h>

struct blink_arg {
    unsigned gpio;
    unsigned half_us;                    /* 반주기 [us] */
};

static const struct blink_arg args[2] = {
    { 17, 10000 },                       /* LED0: 물리 핀 11 (원본 wPi 0), 10 ms */
    { 27, 20000 },                       /* LED1: 물리 핀 13 (원본 wPi 1), 20 ms */
};

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static void *blinky(void *p)
{
    const struct blink_arg *a = p;

    while (running) {
        gpioWrite(a->gpio, 1);
        gpioDelay(a->half_us);
        gpioWrite(a->gpio, 0);
        gpioDelay(a->half_us);
    }
    return NULL;
}

int main(void)
{
    pthread_t th[2];
    int i, k;

    printf("Raspberry Pi blink x2 (pthread + pigpio)\n");

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    for (i = 0; i < 2; i++) {
        gpioSetMode(args[i].gpio, PI_OUTPUT);
        pthread_create(&th[i], NULL, blinky, (void *)&args[i]);
    }

    while (running) {                    /* loop(): 1초마다 출력 */
        printf("Hello, world\n");
        for (k = 0; k < 10 && running; k++)
            gpioDelay(100000);
    }

    for (i = 0; i < 2; i++) {
        pthread_join(th[i], NULL);
        gpioWrite(args[i].gpio, 0);
        gpioSetMode(args[i].gpio, PI_INPUT);
    }
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
