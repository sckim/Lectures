/*
 * thread_args.c : 실습 11-3  pthread 기초 - 스레드 만들기, 기다리기, 인자를 안전하게 넘기기
 *
 * 회로 : 없음 (gpio 값 17~20은 출력용 예시 번호일 뿐 배선하지 않는다. 표준 핀 계획과 무관)
 * 빌드 : gcc -Wall -O2 -pthread -o thread_args thread_args.c   (또는 make thread_args)
 * 실행 : ./thread_args wrong     틀린 방법: 반복문 변수 i의 "주소"를 넘긴다
 *        ./thread_args array     옳은 방법 1: 스레드마다 따로 있는 구조체 배열 원소의 주소
 *        ./thread_args malloc    옳은 방법 2: malloc으로 만든 메모리를 넘기고 스레드가 free
 *        ./thread_args value     옳은 방법 3: 정수 값 자체를 포인터 크기 정수(intptr_t)로 넘긴다
 *
 * 각 스레드는 자기 번호, TID(커널이 보는 스레드 번호), 지역 변수 주소(스택), 전역 변수 주소를 출력한다.
 * PID는 모두 같고 TID는 다르며, 지역 변수 주소는 스레드마다 멀리 떨어져 있음(스택이 따로)을 확인한다.
 */
#define _GNU_SOURCE                       /* gettid() */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#define N_THREADS 4

struct job {                              /* 스레드 하나에게 줄 일감 */
    int id;
    int gpio;                             /* 예: 이 스레드가 맡을 핀 번호 */
};

int shared_global = 0;                    /* 모든 스레드가 같은 주소를 본다 */

static void report(const char *how, int id, int gpio)
{
    int local = id;                       /* 스레드마다 자기 스택에 생긴다 */

    printf("[%s] 스레드 id=%d gpio=%2d  PID=%ld TID=%ld  &local=%p  &shared_global=%p\n",
           how, id, gpio, (long)getpid(), (long)gettid(),
           (void *)&local, (void *)&shared_global);
}

/* 틀린 방법에서 쓰는 함수: main의 i를 "나중에" 읽는다 */
static void *worker_wrong(void *arg)
{
    usleep(1000);                         /* 스레드가 조금 늦게 출발하는 상황(흔하다)을 흉내 */
    int id = *(int *)arg;                 /* 이 순간 main의 i는 이미 바뀌어 있다 */
    report("wrong ", id, 17 + id);
    return NULL;
}

static void *worker_struct(void *arg)
{
    struct job *j = arg;
    report("array ", j->id, j->gpio);
    return NULL;
}

static void *worker_malloc(void *arg)
{
    struct job *j = arg;
    report("malloc", j->id, j->gpio);
    free(j);                              /* 받은 쪽이 해제한다: malloc/free는 반드시 짝 */
    return NULL;
}

static void *worker_value(void *arg)
{
    int id = (int)(intptr_t)arg;          /* 포인터가 아니라 값 그 자체 */
    report("value ", id, 17 + id);
    return NULL;
}

int main(int argc, char *argv[])
{
    pthread_t th[N_THREADS];
    struct job jobs[N_THREADS];           /* main이 끝날 때까지 살아 있다 */
    const char *mode = (argc > 1) ? argv[1] : "array";
    int i;

    printf("main: PID=%ld TID=%ld  &jobs[0]=%p\n",
           (long)getpid(), (long)gettid(), (void *)&jobs[0]);

    for (i = 0; i < N_THREADS; i++) {
        int rc;

        if (strcmp(mode, "wrong") == 0) {
            rc = pthread_create(&th[i], NULL, worker_wrong, &i);       /* 틀림! */
        } else if (strcmp(mode, "malloc") == 0) {
            struct job *j = malloc(sizeof(*j));
            if (j == NULL) { perror("malloc"); return 1; }
            j->id = i;
            j->gpio = 17 + i;
            rc = pthread_create(&th[i], NULL, worker_malloc, j);
            if (rc != 0)
                free(j);                  /* 스레드가 못 받았으면 내가 해제 */
        } else if (strcmp(mode, "value") == 0) {
            rc = pthread_create(&th[i], NULL, worker_value, (void *)(intptr_t)i);
        } else {
            jobs[i].id = i;
            jobs[i].gpio = 17 + i;
            rc = pthread_create(&th[i], NULL, worker_struct, &jobs[i]);
        }
        if (rc != 0) {                    /* pthread 함수는 errno가 아니라 반환값으로 오류를 알린다 */
            fprintf(stderr, "pthread_create: %s\n", strerror(rc));
            return 1;
        }
    }

    for (int k = 0; k < N_THREADS; k++)   /* i를 다시 쓰지 않으려고 k를 썼다 */
        pthread_join(th[k], NULL);        /* 모두 끝날 때까지 기다린다 */

    printf("main: 모든 스레드 종료\n");
    return 0;
}
