/*
 * rht03_pigpio.c : 부록 B  RHT03(= DHT22, AM2302) 온습도 센서 읽기 + 최대/최소 기록
 *
 * 회로 : RHT03 VCC  -> 3.3 V (물리 핀 1)
 *        RHT03 DATA -> GPIO4 (물리 핀 7)      + DATA와 3.3 V 사이 풀업 4.7~10 kΩ
 *        RHT03 GND  -> GND (물리 핀 9)
 * 빌드 : gcc -Wall -pthread -o rht03_pigpio rht03_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./rht03_pigpio
 *
 * 원본 : wiringpi/rht03.c (Raspberry Pi Codes §9.2.3, RHT03_PIN 7 = wPi 7 = GPIO4)
 *        원본은 WiringPi devLib의 readRHT03()(maxdetect.c)에 읽기를 맡기고,
 *        piHiPri(55)로 실시간 우선순위를 올려 타이밍 오차를 줄였다.
 *        pigpio 판은 DMA 샘플링 + 알림 콜백의 tick으로 펄스 폭을 재므로 우선순위를
 *        올릴 필요가 없다. 디코딩 방식은 dht11_pigpio.c와 같다.
 *        readRHT03()처럼 실패하면 한 번 더 읽고, 값의 범위가 터무니없으면 버린다.
 *        readRHT03()은 2초 안에 다시 부르면 지난 값을 돌려주므로, 여기서는 2초마다 읽는다.
 *
 * RHT03(DHT22) 데이터: 습도 16비트, 온도 16비트(최상위 비트 = 음수 부호), 체크섬 8비트
 *                      값은 10배 정수 (예: 235 = 23.5)
 */
#include <stdio.h>
#include <stdint.h>
#include <signal.h>
#include <pigpio.h>

#define RHT03_GPIO    4                  /* wPi 7, 물리 핀 7 */
#define MAX_PULSES    100
#define ONE_THRESH_US 50

static volatile uint32_t widths[MAX_PULSES];
static volatile int n_pulses;
static volatile uint32_t rise_tick;
static volatile int have_rise;
static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static void on_edge(int gpio, int level, uint32_t tick)
{
    (void)gpio;
    if (level == 1) {
        rise_tick = tick;
        have_rise = 1;
    } else if (level == 0 && have_rise) {
        if (n_pulses < MAX_PULSES)
            widths[n_pulses++] = tick - rise_tick;
        have_rise = 0;
    }
}

/* 한 번 읽기. 성공하면 1과 temp, rh (10배 값) */
static int read_once(int *temp, int *rh)
{
    uint8_t d[5] = {0};
    int i, base;

    gpioSetMode(RHT03_GPIO, PI_OUTPUT);
    gpioWrite(RHT03_GPIO, 0);
    gpioDelay(10000);                    /* 시작 신호 10 ms (maxdetect.c와 같은 값) */

    n_pulses = 0;
    have_rise = 0;
    gpioSetMode(RHT03_GPIO, PI_INPUT);
    gpioDelay(50000);

    if (n_pulses < 40)
        return 0;
    base = n_pulses - 40;
    for (i = 0; i < 40; i++) {
        d[i / 8] <<= 1;
        if (widths[base + i] > ONE_THRESH_US)
            d[i / 8] |= 1;
    }
    if (d[4] != (uint8_t)(d[0] + d[1] + d[2] + d[3]))
        return 0;

    *rh = d[0] * 256 + d[1];
    *temp = (d[2] & 0x7F) * 256 + d[3];
    if (d[2] & 0x80)                     /* 음수 */
        *temp = -*temp;

    /* 체크섬이 못 잡는 오류 거르기 (readRHT03과 같은 기준) */
    if (*rh > 999 || *temp > 800 || *temp < -400)
        return 0;
    return 1;
}

static int readRHT03(int *temp, int *rh)
{
    if (read_once(temp, rh))
        return 1;
    gpioDelay(2000000);                  /* 실패하면 2초 뒤 한 번 더 */
    return running && read_once(temp, rh);
}

int main(void)
{
    int temp, rh;
    int minT = 1000, maxT = -1000, minRH = 1000, maxRH = -1000;
    int numGood = 0, numBad = 0;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);
    gpioSetPullUpDown(RHT03_GPIO, PI_PUD_OFF);
    gpioSetAlertFunc(RHT03_GPIO, on_edge);

    while (running) {
        gpioDelay(2000000);              /* 센서 사양: 2초에 한 번까지 */
        if (!running)
            break;

        if (!readRHT03(&temp, &rh)) {
            printf(".");
            fflush(stdout);
            ++numBad;
            continue;
        }
        ++numGood;

        if (temp < minT)  minT = temp;
        if (temp > maxT)  maxT = temp;
        if (rh < minRH)   minRH = rh;
        if (rh > maxRH)   maxRH = rh;

        printf("\r%6d, %6d: ", numGood, numBad);
        printf("Temp: %5.1f, RH: %5.1f%%", temp / 10.0, rh / 10.0);
        printf("  Max/Min Temp: %5.1f:%5.1f", maxT / 10.0, minT / 10.0);
        printf("  Max/Min RH: %5.1f:%5.1f\n", maxRH / 10.0, minRH / 10.0);
    }

    gpioSetAlertFunc(RHT03_GPIO, NULL);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
