/*
 * periodic_gpio.c : 실습 11-8 (선택)  주기 작업의 지터 - pigpio 타이머 콜백 vs 절대 시간 스레드
 *
 * 회로 : GPIO17 (물리 핀 11) -> 330 Ω -> LED -> GND,  AD2 DIO0(또는 Scope 1+)를 GPIO17에, GND 공통
 * 빌드 : gcc -Wall -O2 -pthread -o periodic_gpio periodic_gpio.c -lpigpio -lrt   (또는 make periodic_gpio)
 * 실행 : sudo ./periodic_gpio timer            gpioSetTimerFunc(10 ms)로 GPIO17 토글
 *        sudo ./periodic_gpio thread           clock_nanosleep(TIMER_ABSTIME) 스레드로 GPIO17 토글
 *        sudo chrt -f 50 ./periodic_gpio thread   SCHED_FIFO 우선순위 50으로 실행 (11.5.4절)
 *        [일us]를 셋째 인자로 줄 수 있다. 기본 2000 us
 *
 * 매 주기 시작에 GPIO17을 토글하고 "일"(바쁜 대기 2 ms)을 한다. 토글 간격은 gpioTick()으로도 기록해
 * 끝에 평균/최소/최대를 출력한다. 계측기(10장)로 본 파형의 High/Low 폭과 비교해 보라.
 *   timer : pigpio 타이머 스레드는 "nanosleep(10 ms) -> 콜백"을 반복한다(pigpio.c pthTimerTick).
 *           따라서 실제 주기 = 10 ms + 콜백 시간 + 깨어나는 지연 이 되어 조금씩 밀린다.
 *   thread: 다음 마감 시각을 절대 시각으로 정해 두고 그때까지 자므로 평균 주기가 10 ms로 유지된다.
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <time.h>
#include <pthread.h>
#include <stdatomic.h>
#include <pigpio.h>

#define OUT_GPIO   17            /* 물리 핀 11 */
#define PERIOD_MS  10            /* gpioSetTimerFunc의 최소값이 10 ms이다 */
#define N_PERIODS  500           /* 5초 */

static long work_us = 2000;
static atomic_int running = 1;
static atomic_int n_done = 0;    /* 끝난 주기 수 */
static uint32_t last_tick;
static uint32_t dmin = 0xFFFFFFFFu, dmax = 0;
static uint64_t dsum = 0;
static int level = 0;

static void on_signal(int signum)
{
    (void)signum;
    atomic_store(&running, 0);
}

/* 주기마다 하는 일: 토글 -> 간격 기록 -> 바쁜 일 */
static void one_period(void)
{
    uint32_t now = gpioTick();

    level = !level;
    gpioWrite(OUT_GPIO, level);              /* 계측기는 이 에지 간격을 본다 */

    if (atomic_load(&n_done) > 0) {
        uint32_t d = now - last_tick;
        if (d < dmin) dmin = d;
        if (d > dmax) dmax = d;
        dsum += d;
    }
    last_tick = now;

    while ((uint32_t)(gpioTick() - now) < (uint32_t)work_us)
        ;                                    /* 센서 읽기·계산을 흉내 내는 바쁜 일 */
    atomic_fetch_add(&n_done, 1);
}

static void timer_cb(void)                   /* pigpio 타이머 스레드에서 실행 */
{
    if (atomic_load(&n_done) <= N_PERIODS)
        one_period();
}

static void *periodic_thread(void *arg)      /* 절대 시각으로 깨어나는 스레드 */
{
    struct timespec next;

    (void)arg;
    clock_gettime(CLOCK_MONOTONIC, &next);
    while (atomic_load(&running) && atomic_load(&n_done) <= N_PERIODS) {
        one_period();
        next.tv_nsec += PERIOD_MS * 1000000L;
        if (next.tv_nsec >= 1000000000L) {
            next.tv_nsec -= 1000000000L;
            next.tv_sec++;
        }
        clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &next, NULL);
    }
    return NULL;
}

int main(int argc, char *argv[])
{
    int use_thread = (argc > 1 && strcmp(argv[1], "thread") == 0);
    pthread_t th;

    if (argc > 2)
        work_us = atol(argv[2]);
    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);
    gpioSetMode(OUT_GPIO, PI_OUTPUT);
    gpioWrite(OUT_GPIO, 0);

    printf("%s: 주기 %d ms, 일 %ld us, %d주기 측정 중...\n",
           use_thread ? "thread (clock_nanosleep 절대 시간)" : "timer (gpioSetTimerFunc)",
           PERIOD_MS, work_us, N_PERIODS);

    if (use_thread)
        pthread_create(&th, NULL, periodic_thread, NULL);
    else
        gpioSetTimerFunc(0, PERIOD_MS, timer_cb);

    while (atomic_load(&running) && atomic_load(&n_done) <= N_PERIODS)
        gpioDelay(100000);

    if (use_thread) {
        atomic_store(&running, 0);
        pthread_join(th, NULL);
    } else {
        gpioSetTimerFunc(0, PERIOD_MS, NULL); /* 타이머 해제 */
    }

    int n = atomic_load(&n_done) - 1;        /* 간격 개수 */
    if (n > 0)
        printf("토글 간격  평균 %.3f ms  최소 %.3f ms  최대 %.3f ms  (%d개)\n",
               dsum / (double)n / 1000.0, dmin / 1000.0, dmax / 1000.0, n);

    gpioWrite(OUT_GPIO, 0);
    gpioSetMode(OUT_GPIO, PI_INPUT);
    gpioTerminate();
    return 0;
}
