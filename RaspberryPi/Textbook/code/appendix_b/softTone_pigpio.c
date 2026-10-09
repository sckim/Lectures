/*
 * softTone_pigpio.c : 부록 B  피에조 스피커로 도레미파솔라시도 반복
 *
 * 회로 : GPIO18 (물리 핀 12) -> 수동 피에조(passive piezo) -> GND (물리 핀 14)
 *        교재 표준 배선의 PWM 출력 핀(부저 자리)이다. 두 빌드(기본, -DUSE_DMA_PWM) 모두
 *        같은 핀을 쓰므로 배선을 바꾸지 않고 방식만 비교할 수 있다.
 *        원본은 wPi 3 = GPIO22에 피에조를 달았지만, GPIO22는 교재 표준에서 LED2이다.
 *        스스로 소리를 내는 능동 부저(active buzzer)는 주파수를 바꿔도 음이 거의 같다.
 * 빌드 : gcc -Wall -pthread -o softTone_pigpio softTone_pigpio.c -lpigpio -lrt
 *        gcc -Wall -pthread -DUSE_DMA_PWM -o softTone_dma softTone_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./softTone_pigpio
 *
 * 원본 : wiringpi/softTone.c (Raspberry Pi Codes §4.6.3)
 *        softToneCreate(pin) + softToneWrite(pin, freq)
 *        WiringPi softTone은 핀마다 스레드가 반주기(500000/freq us)마다 핀을 뒤집는다.
 *        아무 핀에서나 되지만 스케줄링 때문에 음정이 흔들릴 수 있고, 최대 5 kHz이다.
 *
 * pigpio로 옮기는 두 가지 방법
 *   기본          gpioHardwarePWM(18, freq, 500000) : 하드웨어 PWM, 듀티 50 %.
 *                 주파수를 1 Hz 단위로 정확하게 낸다. 단, GPIO12/13/18/19에서만 된다.
 *                 그래서 피에조를 원본의 GPIO22에서 GPIO18로 옮겼다.
 *   USE_DMA_PWM   gpioSetPWMfrequency(18, freq) + gpioPWM : 아무 핀에서나 되지만
 *                 주파수를 18개 값 중 가장 가까운 것으로 반올림한다(기본 샘플 5 us일 때
 *                 ... 500, 400, 320, 250 Hz ...). 실행하면 요청값과 실제값을 출력하므로
 *                 음계가 무너지는 것을 직접 확인할 수 있다.
 *   (임의 핀에서 정확한 음을 내려면 웨이브폼 gpioWave* 를 쓴다 - 9장)
 */
#include <stdio.h>
#include <signal.h>
#include <pigpio.h>

#define PIN  18                          /* 물리 핀 12 (하드웨어 PWM0, 원본 wPi 3 = GPIO22) */

static const unsigned scale[8] = { 262, 294, 330, 349, 392, 440, 494, 525 };

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* softToneWrite(pin, freq)에 해당. 실제로 설정된 주파수를 돌려준다. */
static int tone_write(unsigned freq)
{
#ifdef USE_DMA_PWM
    int real = gpioSetPWMfrequency(PIN, freq);    /* 가장 가까운 허용 주파수 */
    gpioPWM(PIN, freq ? gpioGetPWMrange(PIN) / 2 : 0);  /* 듀티 50 % */
    return real;
#else
    gpioHardwarePWM(PIN, freq, freq ? 500000 : 0);   /* 듀티 50 % (백만 분율) */
    return freq;
#endif
}

int main(void)
{
    int i;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);
    gpioSetMode(PIN, PI_OUTPUT);

    printf("GPIO%d 음계 출력 (%s), Ctrl+C로 종료\n", PIN,
#ifdef USE_DMA_PWM
           "DMA PWM: 주파수 반올림됨"
#else
           "하드웨어 PWM"
#endif
    );

    while (running) {
        for (i = 0; i < 8 && running; ++i) {
            int real = tone_write(scale[i]);
            printf("%d: 요청 %3u Hz -> 출력 %3d Hz\n", i, scale[i], real);
            gpioDelay(500000);
        }
    }

    tone_write(0);                       /* 소리 끄기 */
    gpioWrite(PIN, 0);
    gpioSetMode(PIN, PI_INPUT);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
