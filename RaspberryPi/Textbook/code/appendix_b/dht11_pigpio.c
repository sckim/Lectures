/*
 * dht11_pigpio.c : 부록 B  DHT11 온습도 센서를 알림 콜백 + 타임스탬프(tick)로 읽기
 *
 * 회로 : DHT11 VCC  -> 3.3 V (물리 핀 1)      (3.3 V로 구동해야 DATA도 3.3 V가 된다)
 *        DHT11 DATA -> GPIO4 (물리 핀 7)      + DATA와 3.3 V 사이 풀업 4.7~10 kΩ
 *                                              (3핀 모듈은 보통 풀업이 달려 있다)
 *        DHT11 GND  -> GND (물리 핀 9)
 *        교재 표준 배선의 DHT11/RHT03 데이터 핀(rht03_pigpio.c와 같다). 원본의 GPIO21은
 *        교재 표준에서 HC-SR04 ECHO 자리이다.
 * 빌드 : gcc -Wall -pthread -o dht11_pigpio dht11_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./dht11_pigpio
 *
 * 원본 : wiringpi/dht11.c (Raspberry Pi Codes §9.3.2, DHTPIN 29 = wPi 29 = GPIO21)
 *        원본은 digitalRead()를 돌리며 "delayMicroseconds(1)을 몇 번 돌았는가(counter)"로
 *        펄스 길이를 어림했다(counter > 16 이면 1). 이 값은 CPU 속도와 스케줄링에 따라
 *        달라지므로 Pi 모델이나 부하가 바뀌면 자주 "Data not good"이 난다.
 *        pigpio 판은 gpioSetAlertFunc 콜백이 받는 tick(부팅 후 us)으로 High 펄스의 폭을
 *        직접 잰다. 샘플링은 DMA가 5 us마다 하므로 CPU 부하와 무관하다.
 *        참고: pigpio EXAMPLES/Python/DHT11_SENSOR/dht11.py, DHT22_AM2302_SENSOR/DHT22.py
 *
 * DHT11 프로토콜 요약
 *   Pi: 18 ms 이상 Low로 시작 신호 -> 입력으로 전환(풀업이 High로 올림)
 *   센서: 80 us Low, 80 us High로 응답 -> 데이터 40비트
 *   각 비트: 50 us Low 다음 High 26~28 us = 0, 70 us = 1
 *   40비트 = 습도 정수, 습도 소수, 온도 정수, 온도 소수, 체크섬(앞 네 바이트 합의 하위 8비트)
 */
#include <stdio.h>
#include <stdint.h>
#include <signal.h>
#include <pigpio.h>

#define DHT_GPIO      4                  /* 물리 핀 7 (원본 wPi 29 = GPIO21) */
#define MAX_PULSES    100
#define ONE_THRESH_US 50                 /* High 폭이 50 us 보다 길면 비트 1 */

static volatile uint32_t widths[MAX_PULSES];   /* High 펄스 폭 [us] */
static volatile int n_pulses;
static volatile uint32_t rise_tick;
static volatile int have_rise;
static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* 레벨이 바뀔 때마다 pigpio가 부른다. tick은 그 변화가 샘플링된 시각[us] */
static void on_edge(int gpio, int level, uint32_t tick)
{
    (void)gpio;
    if (level == 1) {                    /* 상승: High 시작 시각 기억 */
        rise_tick = tick;
        have_rise = 1;
    } else if (level == 0 && have_rise) {/* 하강: High 폭 = 지금 - 시작 */
        if (n_pulses < MAX_PULSES)
            widths[n_pulses++] = tick - rise_tick;   /* uint32_t 뺄셈: 랩어라운드 안전 */
        have_rise = 0;
    }
}

/* 성공하면 1, data[0..4]에 다섯 바이트 */
static int read_dht11(uint8_t data[5])
{
    int i, base;

    gpioSetMode(DHT_GPIO, PI_OUTPUT);    /* 시작 신호: 18 ms Low */
    gpioWrite(DHT_GPIO, 0);
    gpioDelay(18000);

    n_pulses = 0;                        /* 여기서부터 들어오는 펄스만 센다 */
    have_rise = 0;
    gpioSetMode(DHT_GPIO, PI_INPUT);     /* 선을 놓는다 -> 풀업이 High로 */
    gpioDelay(50000);                    /* 전송(약 5 ms) + 콜백 전달 지연 여유 */

    /* High 펄스: [호스트가 놓은 직후 짧은 High] [응답 80 us] [데이터 40개]
     * 앞부분은 상황에 따라 1~2개이므로 "마지막 40개"를 데이터로 쓴다. */
    if (n_pulses < 40)
        return 0;
    base = n_pulses - 40;

    for (i = 0; i < 5; i++)
        data[i] = 0;
    for (i = 0; i < 40; i++) {
        data[i / 8] <<= 1;
        if (widths[base + i] > ONE_THRESH_US)
            data[i / 8] |= 1;
    }
    return data[4] == (uint8_t)(data[0] + data[1] + data[2] + data[3]);
}

int main(void)
{
    uint8_t d[5];

    printf("Raspberry Pi pigpio DHT11 Temperature test program\n");

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetPullUpDown(DHT_GPIO, PI_PUD_OFF);   /* 외부 풀업을 쓴다 */
    gpioSetAlertFunc(DHT_GPIO, on_edge);

    while (running) {
        if (read_dht11(d)) {
            double f = d[2] * 9.0 / 5.0 + 32;
            printf("Humidity = %d.%d %% Temperature = %d.%d *C (%.1f *F)\n",
                   d[0], d[1], d[2], d[3], f);
        } else {
            printf("Data not good, skip (pulses=%d)\n", n_pulses);
        }
        gpioDelay(1000000);              /* DHT11은 1초에 한 번까지만 읽는다 */
    }

    gpioSetAlertFunc(DHT_GPIO, NULL);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
