/*
 * softpwm_pigpio.c : 부록 B  LED 8개의 밝기를 PWM으로 조절 (아무 GPIO에서나 가능한 PWM)
 *
 * 회로 : 교재 표준 8-LED 바 LED0~LED7 (GPIO 17,27,22,23,24,25,5,6 / 물리 11,13,15,16,18,22,29,31)
 *        원본의 wPi 0~7(GPIO 17,18,27,22,23,24,25,4) 대신, 원본 i번 LED를 LED i로 옮겼다.
 * 빌드 : gcc -Wall -pthread -o softpwm_pigpio softpwm_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./softpwm_pigpio      (Enter를 누르며 단계를 넘긴다, Ctrl+C로 종료)
 *
 * 원본 : wiringpi/softpwm.c (Raspberry Pi Codes §4.6.2)
 *        softPwmCreate(pin, 0, 100) -> gpioSetPWMfrequency(g, 100) + gpioSetPWMrange(g, 100)
 *        softPwmWrite(pin, v)       -> gpioPWM(g, v)
 *
 * 두 방식의 차이
 *   WiringPi softPwm : 핀마다 스레드 하나가 delayMicroseconds로 High/Low를 만든다.
 *                      한 단계 100 us, 범위 100 -> 주기 10 ms(100 Hz). 스케줄링에 따라 흔들린다.
 *   pigpio gpioPWM   : DMA가 5 us(기본)마다 GPIO 레지스터에 미리 만든 패턴을 쓴다.
 *                      CPU를 거의 쓰지 않고 지터가 작다. 주파수는 표에 있는 18개 값 중에서
 *                      고르며(기본 800 Hz), 여기서는 원본과 같은 100 Hz로 맞췄다.
 */
#include <stdio.h>
#include <signal.h>
#include <pigpio.h>

#define RANGE     100
#define NUM_LEDS  8

/*                              LED:   0   1   2   3   4   5   6   7 */
static const unsigned ledMap[NUM_LEDS] = { 17, 27, 22, 23, 24, 25,  5,  6 };
static int values[NUM_LEDS] = { 0, 25, 50, 75, 100, 75, 50, 25 };

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* Enter를 기다린다. Ctrl+C(시그널)로 fgets가 끊기면 0을 돌려준다. */
static int wait_key(void)
{
    char buf[80];

    printf("Press Enter....");
    fflush(stdout);
    return running && fgets(buf, sizeof buf, stdin) != NULL && running;
}

int main(void)
{
    int i, j, t;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    for (i = 0; i < NUM_LEDS; ++i) {
        int f = gpioSetPWMfrequency(ledMap[i], 100);   /* 실제로 설정된 주파수 반환 */
        gpioSetPWMrange(ledMap[i], RANGE);
        gpioPWM(ledMap[i], 0);
        printf("%3d, GPIO%-2u, %3d  (%d Hz)\n", i, ledMap[i], values[i], f);
    }

    if (!wait_key()) goto done;

    /* Bring all up one by one */
    for (i = 0; i < NUM_LEDS && running; ++i)
        for (j = 0; j <= RANGE && running; ++j) {
            gpioPWM(ledMap[i], j);
            gpioDelay(10000);
        }
    if (!wait_key()) goto done;

    /* All down */
    for (i = RANGE; i > 0 && running; --i) {
        for (j = 0; j < NUM_LEDS; ++j)
            gpioPWM(ledMap[j], i);
        gpioDelay(10000);
    }
    if (!wait_key()) goto done;

    /* 밝기 패턴을 한 칸씩 돌린다 */
    while (running) {
        for (i = 0; i < NUM_LEDS; ++i)
            gpioPWM(ledMap[i], values[i]);
        gpioDelay(50000);

        t = values[0];
        for (j = 0; j < NUM_LEDS - 1; ++j)
            values[j] = values[j + 1];
        values[NUM_LEDS - 1] = t;
    }

done:
    for (i = 0; i < NUM_LEDS; ++i) {
        gpioPWM(ledMap[i], 0);
        gpioSetMode(ledMap[i], PI_INPUT);
    }
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
