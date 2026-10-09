/*
 * latency_echo.c : 실습 10-8 (선택)  입력 에지 -> 콜백 -> 출력까지 걸리는 시간 측정
 *
 * AD2 Pattern Generator가 GPIO26에 펄스를 넣으면, 콜백이 GPIO17에 같은 레벨을 쓴다.
 * 로직 분석기로 DIO 2(입력)와 DIO 0(출력)의 에지 사이 시간을 재면 그것이 지연이다.
 *
 * 회로 : AD2 DIO 2 (Patterns, Clock 100 Hz) -> GPIO26 (물리 핀 37)  [Pi 입력]
 *        GPIO17 (물리 핀 11)                 -> AD2 DIO 0             [Pi 출력]
 *        GND (물리 핀 39)                    -> AD2 GND
 * 빌드 : gcc -Wall -O2 -pthread -o latency_echo latency_echo.c -lpigpio -lrt
 * 실행 : sudo ./latency_echo          gpioSetAlertFunc (기본, 5 us 샘플링 + 약 1 ms 주기 전달)
 *        sudo ./latency_echo isr      gpioSetISRFunc  (커널 인터럽트 경유)
 *        Ctrl+C로 끝내면 pigpio가 스스로 본 지연(콜백 시각 - 이벤트 시각) 통계를 출력한다.
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>
#include <pigpio.h>

#define IN_GPIO   26           /* 물리 핀 37 */
#define OUT_GPIO  17           /* 물리 핀 11 */

static volatile sig_atomic_t running = 1;
static uint32_t n_events, lat_min = UINT32_MAX, lat_max;
static uint64_t lat_sum;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* 알림/ISR 콜백 공통: 받은 레벨을 그대로 출력 핀에 복사하고, 지연을 기록한다. */
static void on_edge(int gpio, int level, uint32_t tick)
{
    uint32_t lat;

    (void)gpio;
    if (level > 1)                       /* 2 = 타임아웃(레벨 변화 아님) */
        return;
    gpioWrite(OUT_GPIO, (unsigned)level);

    lat = gpioTick() - tick;             /* 이벤트 시각(tick)부터 지금까지 [us] */
    n_events++;
    lat_sum += lat;
    if (lat < lat_min) lat_min = lat;
    if (lat > lat_max) lat_max = lat;
}

int main(int argc, char *argv[])
{
    int use_isr = (argc > 1 && strcmp(argv[1], "isr") == 0);

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioSetMode(OUT_GPIO, PI_OUTPUT);
    gpioWrite(OUT_GPIO, 0);
    gpioSetMode(IN_GPIO, PI_INPUT);
    gpioSetPullUpDown(IN_GPIO, PI_PUD_DOWN);   /* AD2를 꽂기 전에도 0으로 고정 */

    if (use_isr) {
        if (gpioSetISRFunc(IN_GPIO, EITHER_EDGE, 0, on_edge) != 0) {
            fprintf(stderr, "gpioSetISRFunc 실패: 커널 sysfs GPIO 번호 문제일 수 있다"
                            " (본문 10-8 참고).\n");
            gpioTerminate();
            return 1;
        }
    } else {
        gpioSetAlertFunc(IN_GPIO, on_edge);
    }
    printf("[%s] GPIO%d 에지를 GPIO%d로 복사 중. AD2로 지연을 재고 Ctrl+C\n",
           use_isr ? "gpioSetISRFunc" : "gpioSetAlertFunc", IN_GPIO, OUT_GPIO);

    while (running)
        gpioDelay(100000);

    if (use_isr)
        gpioSetISRFunc(IN_GPIO, EITHER_EDGE, 0, NULL);
    else
        gpioSetAlertFunc(IN_GPIO, NULL);

    if (n_events > 0)
        printf("\n에지 %u개, pigpio가 본 지연: 최소 %u us, 평균 %.1f us, 최대 %u us\n",
               n_events, lat_min, (double)lat_sum / n_events, lat_max);
    else
        printf("\n에지를 하나도 받지 못했다. 배선과 Patterns 실행 상태를 확인하라.\n");

    gpioWrite(OUT_GPIO, 0);
    gpioSetMode(OUT_GPIO, PI_INPUT);
    gpioTerminate();
    return 0;
}
