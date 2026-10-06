/*
 * opt_demo.c : 6.8절  최적화가 코드를 어떻게 바꾸는지, volatile이 왜 필요한지 확인
 *
 * 빌드·비교 : make run      (-O0과 -O2로 각각 빌드해 실행 시간 비교)
 *             make asm      (opt_O0.s, opt_O2.s 생성 → 어셈블리 비교)
 */
#include <stdio.h>
#include <time.h>

#define LOOPS 100000000L     /* 1억 번 */

/* (1) 아무 일도 하지 않는 "시간 끌기" 루프: -O2에서는 통째로 사라진다 */
void delay_plain(void)
{
    for (long i = 0; i < LOOPS; i++)
        ;
}

/* (2) 같은 루프지만 i가 volatile: 매번 메모리에서 읽고 쓰므로 사라지지 않는다 */
void delay_volatile(void)
{
    for (volatile long i = 0; i < LOOPS; i++)
        ;
}

/* (3) 다른 쪽(인터럽트·시그널 처리 함수, 다른 스레드)이 바꿔 줄 플래그를 기다리는 루프 */
int ready_plain;
volatile int ready_volatile;

void wait_plain(void)
{
    while (!ready_plain)        /* -O2: 한 번만 읽고 무한 루프가 될 수 있다 */
        ;
}

void wait_volatile(void)
{
    while (!ready_volatile)     /* 매번 메모리에서 다시 읽는다 */
        ;
}

static double elapsed_ms(void (*fn)(void))
{
    struct timespec t0, t1;

    clock_gettime(CLOCK_MONOTONIC, &t0);
    fn();
    clock_gettime(CLOCK_MONOTONIC, &t1);
    return (t1.tv_sec - t0.tv_sec) * 1e3 + (t1.tv_nsec - t0.tv_nsec) / 1e6;
}

int main(void)
{
    printf("delay_plain    : %8.1f ms\n", elapsed_ms(delay_plain));
    printf("delay_volatile : %8.1f ms\n", elapsed_ms(delay_volatile));

    /* 플래그를 미리 1로 해 두었으므로 두 함수 모두 바로 끝난다.
     * (wait_*의 차이는 실행이 아니라 make asm으로 어셈블리를 보고 확인한다) */
    ready_plain = 1;
    ready_volatile = 1;
    wait_plain();
    wait_volatile();
    return 0;
}
