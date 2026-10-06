/*
 * semaphore_basic.c : 11.10절  카운팅 세마포어 - 주차 공간 2칸에 차 5대
 *
 * 회로 : 없음 (PC(WSL)에서도 실행된다. GPIO 판은 실습 11-6의 semaphore_led.c)
 * 빌드 : gcc -Wall -O2 -pthread -o semaphore_basic semaphore_basic.c   (또는 make semaphore_basic)
 * 실행 : ./semaphore_basic
 *
 * 세마포어 초기값 = 빈 칸 수(2). 차(스레드)는 sem_wait()로 빈 칸을 하나 얻고, 1초 주차한 뒤
 * sem_post()로 돌려준다. 동시에 주차한 차가 2대를 넘지 않는 것을 시각(ms)과 함께 확인한다.
 */
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdatomic.h>

#define N_CARS    5
#define N_SPACES  2

static sem_t parking;                    /* 빈 칸 수를 세는 세마포어 */
static atomic_int inside = 0;            /* 지금 주차 중인 차 수 (확인용) */
static struct timespec t_start;

static long ms_now(void)                 /* 프로그램 시작 후 경과 시간 [ms] */
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (t.tv_sec - t_start.tv_sec) * 1000 + (t.tv_nsec - t_start.tv_nsec) / 1000000;
}

static void *car(void *arg)
{
    int id = (int)(intptr_t)arg;
    int n;

    printf("%5ld ms  차%d 도착, 빈 칸 기다림\n", ms_now(), id);
    sem_wait(&parking);                  /* P: 빈 칸이 0이면 여기서 잠든다 */
    n = atomic_fetch_add(&inside, 1) + 1;
    printf("%5ld ms  차%d 주차   (주차 중 %d대)\n", ms_now(), id, n);

    sleep(1);                            /* 1초 동안 자원(칸)을 쓴다 */

    n = atomic_fetch_sub(&inside, 1) - 1;
    printf("%5ld ms  차%d 출차   (주차 중 %d대)\n", ms_now(), id, n);
    sem_post(&parking);                  /* V: 빈 칸 반납, 기다리던 차 하나가 깨어난다 */
    return NULL;
}

int main(void)
{
    pthread_t th[N_CARS];

    clock_gettime(CLOCK_MONOTONIC, &t_start);
    sem_init(&parking, 0, N_SPACES);     /* 0 = 같은 프로세스의 스레드끼리 공유 */

    for (int i = 0; i < N_CARS; i++) {
        pthread_create(&th[i], NULL, car, (void *)(intptr_t)(i + 1));
        usleep(10000);                   /* 10 ms 간격으로 도착 (출력 순서를 보기 좋게) */
    }
    for (int i = 0; i < N_CARS; i++)
        pthread_join(th[i], NULL);

    sem_destroy(&parking);               /* init과 destroy는 짝 */
    printf("%5ld ms  모든 차 출차 완료\n", ms_now());
    return 0;
}
