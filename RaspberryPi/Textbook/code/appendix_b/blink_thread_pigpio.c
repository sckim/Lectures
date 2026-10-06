/*
 * blink_thread_pigpio.c : 부록 B  스레드 하나가 LED를 점멸하는 동안 main은 따로 출력
 *
 * 회로 : GPIO17 (물리 핀 11) -> 330 Ω -> LED -> GND   (실습 8-2와 같다)
 * 빌드 : gcc -Wall -pthread -o blink_thread_pigpio blink_thread_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./blink_thread_pigpio
 *
 * 원본 : wiringpi/blink_thread.c (Raspberry Pi Codes §4.1.5 첫 번째 코드)
 *        PI_THREAD(blinky) + piThreadCreate(blinky)  ->  POSIX 스레드(pthread_create)
 *        WiringPi의 PI_THREAD는 "void *blinky(void *dummy)"를 만드는 매크로이고,
 *        piThreadCreate는 내부에서 pthread_create를 부를 뿐이다. 11장에서 배우는
 *        pthread를 그대로 쓰면 라이브러리와 무관하게 같은 코드를 쓸 수 있다.
 *
 *        pigpio에도 같은 일을 하는 함수가 있다.
 *            pthread_t *th = gpioStartThread(blinky, NULL);   ...   gpioStopThread(th);
 *        gpioStopThread는 스레드를 취소(pthread_cancel)하므로, 이 예제처럼
 *        플래그로 스스로 끝나게 하는 편이 LED를 확실히 끄고 나올 수 있다.
 */
#include <stdio.h>
#include <signal.h>
#include <pthread.h>
#include <pigpio.h>

#define LED_GPIO  17                     /* wPi 0, 물리 핀 11 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* PI_THREAD(blinky) 에 해당하는 스레드 함수 */
static void *blinky(void *arg)
{
    (void)arg;
    while (running) {
        gpioWrite(LED_GPIO, 1);          /* On */
        gpioDelay(500000);               /* 500 ms */
        gpioWrite(LED_GPIO, 0);          /* Off */
        gpioDelay(500000);
    }
    return NULL;
}

int main(void)
{
    pthread_t th;
    int i;

    printf("Raspberry Pi blink (pthread + pigpio)\n");

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);
    gpioSetMode(LED_GPIO, PI_OUTPUT);

    if (pthread_create(&th, NULL, blinky, NULL) != 0) {   /* piThreadCreate(blinky) */
        fprintf(stderr, "스레드 생성 실패\n");
        gpioTerminate();
        return 1;
    }

    while (running) {
        printf("Hello, world\n");
        for (i = 0; i < 20 && running; i++)   /* 2초를 0.1초씩 나눠 기다려 */
            gpioDelay(100000);                /* Ctrl+C에 빨리 반응한다   */
    }

    pthread_join(th, NULL);              /* 스레드가 루프를 빠져나올 때까지 기다림 */
    gpioWrite(LED_GPIO, 0);
    gpioSetMode(LED_GPIO, PI_INPUT);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
