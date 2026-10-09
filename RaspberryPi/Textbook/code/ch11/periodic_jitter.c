/*
 * periodic_jitter.c : 실습 11-8(준비)  주기 작업 - 상대 시간 sleep과 절대 시간 sleep 비교
 *
 * 회로 : 없음 (PC(WSL)에서도 실행된다. GPIO 판은 periodic_gpio.c)
 * 빌드 : gcc -Wall -O2 -pthread -o periodic_jitter periodic_jitter.c   (또는 make periodic_jitter)
 * 실행 : ./periodic_jitter rel [주기ms] [일us] [횟수]    "일 -> 주기만큼 잠"   (pigpio 타이머 방식)
 *        ./periodic_jitter abs [주기ms] [일us] [횟수]    "다음 마감 시각까지 잠" (clock_nanosleep 절대 시간)
 *        기본값: 주기 10 ms, 일 2000 us, 200회
 *        sudo chrt -f 50 ./periodic_jitter abs           실시간 우선순위(SCHED_FIFO 50)로 실행 (11.5.4절)
 *
 * rel: nanosleep(주기)를 일이 끝난 "뒤에" 부르므로 실제 주기 = 주기 + 일 시간 + 깨어나는 지연이 되어
 *      시간이 갈수록 이상적인 시각보다 점점 늦어진다(누적 드리프트).
 * abs: 시작 시각 + k*주기 라는 절대 시각까지 자므로, 한 번 늦어도 다음 주기에서 따라잡는다.
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define NSEC_PER_SEC 1000000000L

static long long ts_ns(const struct timespec *t)
{
    return (long long)t->tv_sec * NSEC_PER_SEC + t->tv_nsec;
}

static void busy_work_us(long us)               /* 센서 읽기·계산을 흉내 내는 바쁜 일 */
{
    struct timespec t0, t;
    clock_gettime(CLOCK_MONOTONIC, &t0);
    do {
        clock_gettime(CLOCK_MONOTONIC, &t);
    } while (ts_ns(&t) - ts_ns(&t0) < us * 1000LL);
}

int main(int argc, char *argv[])
{
    int use_abs  = (argc > 1 && strcmp(argv[1], "abs") == 0);
    long period_ms = (argc > 2) ? atol(argv[2]) : 10;
    long work_us   = (argc > 3) ? atol(argv[3]) : 2000;
    int  n         = (argc > 4) ? atoi(argv[4]) : 200;
    long long period_ns = period_ms * 1000000LL;
    struct timespec start, now, next, rel;
    long long prev = 0, dmin = 1LL << 62, dmax = 0, sum = 0;

    rel.tv_sec  = period_ms / 1000;
    rel.tv_nsec = (period_ms % 1000) * 1000000L;

    clock_gettime(CLOCK_MONOTONIC, &start);
    next = start;

    for (int k = 0; k <= n; k++) {
        clock_gettime(CLOCK_MONOTONIC, &now);
        long long t = ts_ns(&now);
        if (k > 0) {                             /* 이번 시작 - 지난번 시작 = 실제 주기 */
            long long d = t - prev;
            if (d < dmin) dmin = d;
            if (d > dmax) dmax = d;
            sum += d;
        }
        prev = t;
        if (k == n)
            break;

        busy_work_us(work_us);                   /* 주기마다 할 일 */

        if (use_abs) {
            next.tv_nsec += period_ns % NSEC_PER_SEC;
            next.tv_sec  += period_ns / NSEC_PER_SEC;
            if (next.tv_nsec >= NSEC_PER_SEC) {
                next.tv_nsec -= NSEC_PER_SEC;
                next.tv_sec++;
            }
            clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &next, NULL);
        } else {
            nanosleep(&rel, NULL);               /* pigpio의 gpioSetTimerFunc 내부와 같은 방식 */
        }
    }

    long long ideal_end = ts_ns(&start) + n * period_ns;
    printf("%s: 주기 %ld ms, 일 %ld us, %d회\n",
           use_abs ? "abs (clock_nanosleep TIMER_ABSTIME)" : "rel (일 + nanosleep)",
           period_ms, work_us, n);
    printf("  실제 주기  평균 %.3f ms  최소 %.3f ms  최대 %.3f ms\n",
           sum / (double)n / 1e6, dmin / 1e6, dmax / 1e6);
    printf("  %d회 뒤 이상적인 시각보다 %.1f ms 늦음 (누적 드리프트)\n",
           n, (prev - ideal_end) / 1e6);
    return 0;
}
