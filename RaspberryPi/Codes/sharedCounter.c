#include <stdio.h>
#include <pthread.h>
#include <wiringPi.h>

#define LOOP_COUNT 100000  // 각 스레드가 수행할 덧셈 횟수

// 1. 공유 자원 (전역 변수)
int sharedCounter = 0;

// 2. 뮤텍스 객체 선언 (잠금 장치)
pthread_mutex_t lock;

// 스레드가 실행할 함수
void* threadFunction(void* arg) {
    char* threadName = (char*)arg;

    for (int i = 0; i < LOOP_COUNT; i++) {
        // === 임계 구역 (Critical Section) 진입 ===
        // 여기서 잠그지 않으면 두 스레드가 동시에 접근하여 데이터가 꼬임
        pthread_mutex_lock(&lock); 
        
        // 공유 자원 작업
        int temp = sharedCounter;
        temp = temp + 1;
        
        // 실제 하드웨어 제어 시 발생할 수 있는 미세한 지연을 시뮬레이션
        // (이 지연이 있으면 충돌 확률이 비약적으로 상승함)
        delayMicroseconds(1); // 필요시 주석 해제하여 테스트
        
        sharedCounter = temp;
        
        // === 임계 구역 탈출 ===
        pthread_mutex_unlock(&lock); 
    }
    
    printf("%s 완료\n", threadName);
    return NULL;
}

int main() {
    pthread_t t1, t2;

    // WiringPi 초기화 (GPIO를 안 써도 타이밍 함수 등을 위해 습관적으로 해주는 것이 좋음)
    if (wiringPiSetup() == -1) return 1;

    // 뮤텍스 초기화
    pthread_mutex_init(&lock, NULL);

    printf("=== 뮤텍스 테스트 시작 (목표값: %d) ===\n", LOOP_COUNT * 2);

    // 스레드 2개 생성 (T1, T2)
    pthread_create(&t1, NULL, threadFunction, "Thread_1");
    pthread_create(&t2, NULL, threadFunction, "Thread_2");

    // 두 스레드가 끝날 때까지 메인 스레드 대기 (Join)
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    // 결과 출력
    printf("최종 카운트 값: %d\n", sharedCounter);

    if (sharedCounter == LOOP_COUNT * 2) {
        printf("결과: 성공! (데이터 손실 없음)\n");
    } else {
        printf("결과: 실패! (Race Condition 발생)\n");
    }

    // 뮤텍스 제거
    pthread_mutex_destroy(&lock);

    return 0;
}