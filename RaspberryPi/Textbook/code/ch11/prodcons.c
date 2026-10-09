/*
 * prodcons.c : 11.9절  생산자-소비자 - 뮤텍스와 조건 변수로 만든 유한 큐(ring buffer)
 *
 * 회로 : 없음 (PC(WSL)에서도 실행된다. 버튼 콜백 판은 실습 11-7의 button_queue.c)
 * 빌드 : gcc -Wall -O2 -pthread -o prodcons prodcons.c   (또는 make prodcons)
 * 실행 : ./prodcons
 *
 * 생산자(센서 읽기 스레드)는 50 ms마다 값을 만들고, 소비자(기록 스레드)는 하나 처리에 120 ms가 걸린다.
 * 큐는 4칸이다. 큐가 차면 생산자가 기다리고(not_full), 비면 소비자가 기다린다(not_empty).
 * 바쁜 대기(while 문으로 계속 확인) 없이 잠들었다가 신호를 받으면 깨어난다.
 */
#include <stdio.h>
#include <stdbool.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>

#define QSIZE    4
#define N_ITEMS  10

static int queue[QSIZE];
static int head = 0, tail = 0, count = 0;      /* 꺼낼 위치, 넣을 위치, 들어 있는 개수 */
static bool done = false;                      /* 생산 끝 표시 (lock 안에서만 읽고 쓴다) */

static pthread_mutex_t qlock    = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t not_empty = PTHREAD_COND_INITIALIZER;
static pthread_cond_t not_full  = PTHREAD_COND_INITIALIZER;
static struct timespec t_start;

static long ms_now(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (t.tv_sec - t_start.tv_sec) * 1000 + (t.tv_nsec - t_start.tv_nsec) / 1000000;
}

static void *producer(void *arg)
{
    (void)arg;
    for (int i = 1; i <= N_ITEMS; i++) {
        int value = 200 + i;                   /* "센서 값" */
        usleep(50000);                         /* 50 ms마다 하나 */

        pthread_mutex_lock(&qlock);
        while (count == QSIZE) {               /* 꽉 찼으면 빈자리가 날 때까지 잠든다 */
            printf("%5ld ms  [생산자] 큐가 가득 참 -> 대기\n", ms_now());
            pthread_cond_wait(&not_full, &qlock);
        }
        queue[tail] = value;
        tail = (tail + 1) % QSIZE;
        count++;
        printf("%5ld ms  [생산자] %d 넣음 (큐 %d개)\n", ms_now(), value, count);
        pthread_cond_signal(&not_empty);       /* 기다리는 소비자를 깨운다 */
        pthread_mutex_unlock(&qlock);
    }

    pthread_mutex_lock(&qlock);
    done = true;
    pthread_cond_signal(&not_empty);
    pthread_mutex_unlock(&qlock);
    return NULL;
}

static void *consumer(void *arg)
{
    (void)arg;
    for (;;) {
        int value;

        pthread_mutex_lock(&qlock);
        while (count == 0 && !done)            /* if가 아니라 while: 깨어나면 조건을 다시 확인 */
            pthread_cond_wait(&not_empty, &qlock);
        if (count == 0 && done) {              /* 더 올 것도 없고 남은 것도 없다 */
            pthread_mutex_unlock(&qlock);
            break;
        }
        value = queue[head];
        head = (head + 1) % QSIZE;
        count--;
        pthread_cond_signal(&not_full);        /* 기다리는 생산자를 깨운다 */
        pthread_mutex_unlock(&qlock);

        /* 오래 걸리는 처리는 잠금을 풀고 한다 (잠근 채로 하면 생산자가 그동안 못 넣는다) */
        printf("%5ld ms  [소비자]     %d 처리 시작\n", ms_now(), value);
        usleep(120000);
    }
    printf("%5ld ms  [소비자] 끝\n", ms_now());
    return NULL;
}

int main(void)
{
    pthread_t p, c;

    clock_gettime(CLOCK_MONOTONIC, &t_start);
    pthread_create(&c, NULL, consumer, NULL);
    pthread_create(&p, NULL, producer, NULL);
    pthread_join(p, NULL);
    pthread_join(c, NULL);
    return 0;
}
