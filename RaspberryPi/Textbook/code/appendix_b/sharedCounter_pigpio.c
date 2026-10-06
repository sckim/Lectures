/*
 * sharedCounter_pigpio.c : 부록 B  두 스레드가 전역 변수 하나를 함께 증가시키는 race condition 실험
 *
 * 회로 : 없음 (GPIO를 쓰지 않는다. gpioDelay를 쓰기 위해서만 pigpio를 초기화한다)
 * 빌드 : gcc -Wall -pthread -o sharedCounter_pigpio sharedCounter_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./sharedCounter_pigpio          뮤텍스 사용 -> 항상 성공
 *        sudo ./sharedCounter_pigpio nolock   뮤텍스 없이 -> 대부분 실패(값 손실)
 *
 * 원본 : wiringpi/sharedCounter.c (저장소 Codes/sharedCounter.c, Raspberry Pi Codes §4.1.6)
 *        wiringPiSetup() -> gpioInitialise(), delayMicroseconds(1) -> gpioDelay(1)
 *        원본은 뮤텍스를 쓴 경우만 보여 주므로, 비교할 수 있게 "nolock" 옵션을 더했다.
 *        스레드 이름은 문자열 상수(정적 저장 공간)이므로 그 주소를 넘겨도 안전하다.
 *
 * 참고 : gpioDelay(1)은 pigpio가 매핑한 시스템 타이머를 1 us 동안 바쁜 대기(busy-wait)한다.
 *        이 지연이 임계 구역 안에 있으면 두 스레드가 겹칠 확률이 크게 올라간다.
 *        결과 해석과 mutex의 원리는 11장에서 다룬다.
 */
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <pigpio.h>

#define LOOP_COUNT 100000              /* 각 스레드가 수행할 덧셈 횟수 */

static int sharedCounter = 0;          /* 공유 자원 */
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static int use_lock = 1;

static void *threadFunction(void *arg)
{
    const char *threadName = arg;

    for (int i = 0; i < LOOP_COUNT; i++) {
        if (use_lock)
            pthread_mutex_lock(&lock);       /* === 임계 구역 진입 === */

        int temp = sharedCounter;            /* 읽고 */
        temp = temp + 1;                     /* 고치고 */
        gpioDelay(1);                        /* 하드웨어 접근 같은 미세 지연 흉내 */
        sharedCounter = temp;                /* 쓴다 */

        if (use_lock)
            pthread_mutex_unlock(&lock);     /* === 임계 구역 탈출 === */
    }
    printf("%s 완료\n", threadName);
    return NULL;
}

int main(int argc, char *argv[])
{
    pthread_t t1, t2;

    if (argc > 1 && strcmp(argv[1], "nolock") == 0)
        use_lock = 0;

    if (gpioInitialise() < 0) {              /* gpioDelay를 쓰려면 초기화가 필요하다 */
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }

    printf("=== %s 테스트 시작 (목표값: %d) ===\n",
           use_lock ? "뮤텍스" : "뮤텍스 없음", LOOP_COUNT * 2);

    pthread_create(&t1, NULL, threadFunction, "Thread_1");
    pthread_create(&t2, NULL, threadFunction, "Thread_2");
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    printf("최종 카운트 값: %d\n", sharedCounter);
    if (sharedCounter == LOOP_COUNT * 2)
        printf("결과: 성공! (데이터 손실 없음)\n");
    else
        printf("결과: 실패! (Race Condition 발생, %d회 손실)\n",
               LOOP_COUNT * 2 - sharedCounter);

    gpioTerminate();
    return 0;
}
