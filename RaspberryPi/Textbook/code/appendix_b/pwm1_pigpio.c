/*
 * pwm1_pigpio.c : 부록 B  하드웨어 PWM 두 채널로 LED 두 개를 서로 반대로 밝게/어둡게
 *
 * 회로 : GPIO18 (물리 핀 12, PWM0) -> 330 Ω -> LED -> GND   (교재 표준 PWM 출력 핀)
 *        GPIO13 (물리 핀 33, PWM1) -> 330 Ω -> LED -> GND   (서보 신호 핀을 빌려 쓴다.
 *                                    서보를 빼고 LED를 꽂는다. 1 kHz는 서보에 넣으면 안 된다)
 *        GPIO17 (물리 핀 11, LED0) -> 330 Ω -> LED -> GND   (고정 밝기, 아래 설명)
 * 빌드 : gcc -Wall -pthread -o pwm1_pigpio pwm1_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./pwm1_pigpio
 *
 * 원본 : wiringpi/pwm1.c (Raspberry Pi Codes §4.6.1)
 *        pwmSetMode(PWM_MODE_MS) + pinMode(pin, PWM_OUTPUT) + pwmWrite(pin, 0~1024)
 *          -> gpioHardwarePWM(gpio, 주파수[Hz], 듀티 0~1000000)
 *        pigpio의 하드웨어 PWM은 항상 mark-space 방식이고, 듀티를 백만 분율로 받는다.
 *        그래서 원본의 0~1024 값을 value * 1000000 / 1024 로 바꾼다.
 *
 * 고친 점: GPIO12와 GPIO18은 같은 채널(PWM0)에 연결된다. 한 채널에는 듀티가 하나뿐이므로
 *        원본처럼 GPIO12에 500, GPIO18에 intensity를 쓰면 마지막에 쓴 값이 두 핀에
 *        모두 적용되어 GPIO12가 "고정 밝기"가 되지 않는다.
 *        -> 하드웨어 PWM은 채널마다 한 핀씩, GPIO18(PWM0)과 GPIO13(PWM1)만 쓴다.
 *           원본의 GPIO12 고정 밝기 LED는 pigpio의 DMA PWM(gpioPWM, 아무 GPIO에서나
 *           가능)으로 옮겨 LED0(GPIO17)에서 낸다. GPIO12는 교재 표준 배선에서
 *           DS1302 CE 자리이므로 쓰지 않는다.
 *
 * 참고 : Pi 4의 3.5 mm 아날로그 오디오도 PWM 주변장치를 쓴다. 소리를 재생 중이면
 *        하드웨어 PWM 출력이 흔들릴 수 있다.
 */
#include <stdio.h>
#include <signal.h>
#include <pigpio.h>

#define LED0_SOFT    17                  /* 물리 핀 11 : DMA PWM으로 고정 듀티 (원본 GPIO12) */
#define BCM13_PWM1   13                  /* 물리 핀 33 : 하드웨어 PWM1 */
#define BCM18_PWM0   18                  /* 물리 핀 12 : 하드웨어 PWM0 */
#define PWM_FREQ     1000                /* 1 kHz */
#define WPI_RANGE    1024                /* 원본(WiringPi)의 기본 범위 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* WiringPi 0~1024 값 -> pigpio 하드웨어 PWM 듀티 0~1000000 */
static unsigned to_duty(int value)
{
    return (unsigned)((long)value * PI_HW_PWM_RANGE / WPI_RANGE);
}

static void set_pair(int intensity)
{
    gpioHardwarePWM(BCM18_PWM0, PWM_FREQ, to_duty(intensity));
    gpioHardwarePWM(BCM13_PWM1, PWM_FREQ, to_duty(WPI_RANGE - intensity));
}

int main(void)
{
    int intensity;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetPWMrange(LED0_SOFT, WPI_RANGE);       /* DMA PWM 범위를 0~1024로 */
    gpioPWM(LED0_SOFT, 500);                     /* 원본의 pwmWrite(12, 500) */

    while (running) {
        for (intensity = 0; intensity < WPI_RANGE && running; ++intensity) {
            set_pair(intensity);
            gpioDelay(1000);                     /* delay(1) */
        }
        for (intensity = WPI_RANGE - 1; intensity >= 0 && running; --intensity) {
            set_pair(intensity);
            gpioDelay(1000);
        }
    }

    gpioHardwarePWM(BCM18_PWM0, 0, 0);           /* 주파수 0 = PWM 끄기 */
    gpioHardwarePWM(BCM13_PWM1, 0, 0);
    gpioPWM(LED0_SOFT, 0);
    gpioSetMode(BCM18_PWM0, PI_INPUT);
    gpioSetMode(BCM13_PWM1, PI_INPUT);
    gpioSetMode(LED0_SOFT, PI_INPUT);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
