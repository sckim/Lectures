/*
 * shared_counter.c : 실습 11-4  race condition과 그 해결 (mutex, atomic)
 *
 * 회로 : 없음 (pigpio 없이 표준 C와 pthread만 쓴다. PC(WSL)에서도 실행된다)
 * 빌드 : make shared_counter shared_counter_mutex shared_counter_atomic
 *        gcc -Wall -O2 -pthread -o shared_counter        shared_counter.c               보호 없음
 *        gcc -Wall -O2 -pthread -o shared_counter_mutex  shared_counter.c -DUSE_MUTEX   뮤텍스
 *        gcc -Wall -O2 -pthread -o shared_counter_atomic shared_counter.c -DUSE_ATOMIC  원자적 연산
 * 실행 : ./shared_counter [반복 횟수] [스레드 수]     기본 100000회, 2개 (강의 예제와 같다)
 *
 * 원본 : Raspberry Pi Codes §4.1.6 sharedCounter.c (WiringPi). 부록 B의 sharedCounter_pigpio.c와 같은 실험.
 * 바꾼 점
 *   1) GPIO를 쓰지 않으므로 라이브러리 초기화를 뺐다.
 *   2) 보호 없음 / 뮤텍스 / 원자적 연산 세 가지를 컴파일 옵션(-D)으로 고른다.
 *   3) 보호 없음 판의 카운터는 일부러 volatile로 선언했다. volatile이어도 값이 틀린다는 것을 보이기 위해서다.
 *   4) 장벽(barrier)으로 모든 스레드가 "동시에" 출발하게 했다. 없으면 코어가 많은 PC에서는
 *      첫 스레드가 두 번째 스레드가 생기기도 전에 끝나 버려 충돌이 잘 안 보인다.
 *   5) 걸린 시간을 재서 보호 방법의 비용을 비교한다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>

#if defined(USE_ATOMIC)
#include <stdatomic.h>
static atomic_int sharedCounter = 0;              /* C11 원자적 정수 */
#define MODE "atomic (atomic_fetch_add)"
#elif defined(USE_MUTEX)
static int sharedCounter = 0;
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
#define MODE "mutex (pthread_mutex_lock/unlock)"
#else
static volatile int sharedCounter = 0;            /* volatile은 동기화 수단이 아니다! */
#define MODE "보호 없음 (volatile int)"
#endif

static long loop_count = 100000;
static pthread_barrier_t start_line;              /* 출발선: 모두 모이면 함께 출발 */

static void *threadFunction(void *arg)
{
    (void)arg;
    pthread_barrier_wait(&start_line);

    for (long i = 0; i < loop_count; i++) {
#if defined(USE_ATOMIC)
        atomic_fetch_add(&sharedCounter, 1);      /* 읽기-더하기-쓰기를 한 덩어리로 */
#elif defined(USE_MUTEX)
        pthread_mutex_lock(&lock);                /* === 임계 구역 진입 === */
        sharedCounter = sharedCounter + 1;
        pthread_mutex_unlock(&lock);              /* === 임계 구역 탈출 === */
#else
        sharedCounter = sharedCounter + 1;        /* 읽기 -> 더하기 -> 쓰기 (세 단계) */
#endif
    }
    return NULL;
}

int main(int argc, char *argv[])
{
    int n_threads = 2;
    pthread_t th[64];
    struct timespec t0, t1;

    if (argc > 1) loop_count = atol(argv[1]);
    if (argc > 2) n_threads = atoi(argv[2]);
    if (n_threads < 1 || n_threads > 64) n_threads = 2;

    long expected = loop_count * n_threads;
    printf("=== %s : 스레드 %d개 x %ld회 (목표값 %ld) ===\n",
           MODE, n_threads, loop_count, expected);

    pthread_barrier_init(&start_line, NULL, (unsigned)n_threads);
    clock_gettime(CLOCK_MONOTONIC, &t0);
    for (int i = 0; i < n_threads; i++)
        pthread_create(&th[i], NULL, threadFunction, NULL);
    for (int i = 0; i < n_threads; i++)
        pthread_join(th[i], NULL);
    clock_gettime(CLOCK_MONOTONIC, &t1);
    pthread_barrier_destroy(&start_line);

    long result = sharedCounter;
    double ms = (t1.tv_sec - t0.tv_sec) * 1e3 + (t1.tv_nsec - t0.tv_nsec) / 1e6;
    printf("최종 카운트 값: %ld  (%.1f ms)\n", result, ms);
    if (result == expected)
        printf("결과: 성공 (데이터 손실 없음)\n");
    else
        printf("결과: 실패 (race condition, %ld회 손실 = %.1f%%)\n",
               expected - result, 100.0 * (expected - result) / expected);
    return 0;
}
