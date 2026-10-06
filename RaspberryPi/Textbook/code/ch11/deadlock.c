/*
 * deadlock.c : 실습 11-5  교착 상태(deadlock) 만들기와 고치기
 *
 * 회로 : 없음
 * 빌드 : gcc -Wall -O2 -pthread -o deadlock deadlock.c   (또는 make deadlock)
 * 실행 : ./deadlock          두 스레드가 자원을 반대 순서로 잡는다 -> 멈춘다 (Ctrl+C로 끝낸다)
 *        ./deadlock fix      두 스레드가 같은 순서(LED -> UART)로 잡는다 -> 정상 종료
 *
 * 상황 : 스레드 A는 "LED 상태를 UART로 보고"하고, 스레드 B는 "UART로 받은 명령을 LED에 반영"한다.
 *        둘 다 LED 자원과 UART 자원을 모두 잡아야 일할 수 있다.
 *        A는 LED -> UART 순서로, B는 UART -> LED 순서로 잡으면 서로 상대가 쥔 열쇠를 기다리며 영원히 멈춘다.
 */
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

static pthread_mutex_t led_lock  = PTHREAD_MUTEX_INITIALIZER;   /* LED 자원 */
static pthread_mutex_t uart_lock = PTHREAD_MUTEX_INITIALIZER;   /* UART 자원 */
static int fixed = 0;                    /* 1이면 잠금 순서를 통일한다 */

static void *task_a(void *arg)           /* LED 상태를 UART로 보고 */
{
    (void)arg;
    for (int n = 1; n <= 3; n++) {
        pthread_mutex_lock(&led_lock);
        printf("A: LED 잡음, UART 기다림 (%d회차)\n", n);
        fflush(stdout);
        usleep(100000);                  /* 100 ms: 그 사이 B가 UART를 잡는다 */
        pthread_mutex_lock(&uart_lock);
        printf("A: LED+UART 모두 잡음 -> 보고 완료\n");
        pthread_mutex_unlock(&uart_lock);
        pthread_mutex_unlock(&led_lock);
    }
    return NULL;
}

static void *task_b(void *arg)           /* UART 명령을 LED에 반영 */
{
    (void)arg;
    for (int n = 1; n <= 3; n++) {
        if (fixed) {                     /* 고친 판: A와 같은 순서 (LED -> UART) */
            pthread_mutex_lock(&led_lock);
            printf("B: LED 잡음, UART 기다림 (%d회차)\n", n);
            fflush(stdout);
            usleep(100000);
            pthread_mutex_lock(&uart_lock);
        } else {                         /* 원래 판: 반대 순서 (UART -> LED) */
            pthread_mutex_lock(&uart_lock);
            printf("B: UART 잡음, LED 기다림 (%d회차)\n", n);
            fflush(stdout);
            usleep(100000);
            pthread_mutex_lock(&led_lock);
        }
        printf("B: UART+LED 모두 잡음 -> 명령 반영 완료\n");
        pthread_mutex_unlock(&led_lock);
        pthread_mutex_unlock(&uart_lock);
    }
    return NULL;
}

int main(int argc, char *argv[])
{
    pthread_t a, b;

    fixed = (argc > 1 && strcmp(argv[1], "fix") == 0);
    printf("=== %s (PID %ld) ===\n", fixed ? "잠금 순서 통일" : "잠금 순서 반대",
           (long)getpid());

    pthread_create(&a, NULL, task_a, NULL);
    pthread_create(&b, NULL, task_b, NULL);
    pthread_join(a, NULL);
    pthread_join(b, NULL);

    printf("=== 두 스레드 모두 정상 종료 ===\n");
    return 0;
}
