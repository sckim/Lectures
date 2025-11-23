#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>     // sleep 함수용
#include <pthread.h>    // 스레드 라이브러리
#include <semaphore.h>  // 세마포어 라이브러리
#include <wiringPi.h>

// === 핀 설정 (WiringPi 핀 번호 기준) ===
#define LED_1 0
#define LED_2 1
#define LED_3 2
#define BUTTON_PIN 3

// === 설정 값 ===
#define MAX_CONCURRENT_LEDS 2  // 동시에 켤 수 있는 LED 개수 (세마포어 초기값)

// === 전역 객체 ===
sem_t sem_led;  // 세마포어 객체 선언

// === LED 제어 스레드 함수 ===
// 버튼이 눌릴 때마다 이 함수를 실행하는 스레드가 생성됨
void* blinkTask(void* arg) {
    int thread_id = *(int*)arg;
    free(arg); // 동적 할당된 메모리 해제

    printf("[요청] %d번 스레드: LED 켜기 대기 중...\n", thread_id);

    // 1. 세마포어 대기 (Wait / P 연산)
    // - 카운트가 0보다 크면: 카운트 1 감소 후 즉시 통과 (LED 켜짐)
    // - 카운트가 0이면: 자리가 날 때까지 여기서 무한 대기 (Blocking)
    sem_wait(&sem_led);

    // --- 여기부터는 허용된 스레드만 진입 가능 (최대 2명) ---
    
    printf("  >> [진입] %d번 스레드: 자원을 획득했습니다! LED ON\n", thread_id);

    // 가상의 '사용 가능한' LED를 찾아 켜는 로직
    // (단순화를 위해 실제 핀 제어는 모든 핀을 켜는 척하거나 랜덤하게 수행)
    // 여기서는 시각적 확인을 위해 모든 LED 핀에 신호를 주지만,
    // 실제로는 물리적으로 2개만 켜지도록 제한하는 논리적 구역임.
    digitalWrite(LED_1, HIGH); 
    digitalWrite(LED_2, HIGH);
    
    // 3초간 점등 (자원 점유 시간)
    sleep(3);

    digitalWrite(LED_1, LOW);
    digitalWrite(LED_2, LOW);

    printf("  << [반납] %d번 스레드: 작업 완료. 자원 반납.\n", thread_id);

    // 2. 세마포어 신호 (Signal / V 연산)
    // - 카운트 1 증가 (빈자리 생김)
    // - 대기 중인 다른 스레드가 있다면 깨워서 들여보냄
    sem_post(&sem_led);

    return NULL;
}

int main() {
    pthread_t t_id;
    int task_count = 0;

    // 1. WiringPi 초기화
    if (wiringPiSetup() == -1) {
        printf("WiringPi 초기화 실패!\n");
        return 1;
    }

    // 2. 핀 모드 설정
    pinMode(LED_1, OUTPUT);
    pinMode(LED_2, OUTPUT);
    pinMode(LED_3, OUTPUT);
    pinMode(BUTTON_PIN, INPUT);
    pullUpDnControl(BUTTON_PIN, PUD_DOWN); // 내부 풀다운 저항 활성화 (필요시 PUD_UP 변경)

    // 초기 상태: LED 끄기
    digitalWrite(LED_1, LOW);
    digitalWrite(LED_2, LOW);
    digitalWrite(LED_3, LOW);

    // 3. 세마포어 초기화
    // 인자: (세마포어 주소, 프로세스간 공유여부(0:스레드간), 초기 카운트 값)
    // 여기서 초기값을 2로 설정했으므로, 동시에 2개의 스레드만 통과 가능!
    sem_init(&sem_led, 0, MAX_CONCURRENT_LEDS);

    printf("=== 세마포어 LED 시스템 시작 ===\n");
    printf("버튼을 누르면 작업이 추가됩니다. (동시 허용: %d개)\n", MAX_CONCURRENT_LEDS);

    while(1) {
        // 버튼 입력 감지 (간단한 디바운싱 처리 포함)
        if (digitalRead(BUTTON_PIN) == HIGH) {
            task_count++;
            
            // 스레드에 넘겨줄 ID (동적 할당 필요)
            // 이유: 지역 변 주소를 넘기면 스레드 실행 전에 값이 바뀔 수 있음
            int* id_arg = (int*)malloc(sizeof(int));
            *id_arg = task_count;

            // 스레드 생성 (Detach 모드로 실행하거나 여기선 간단히 create만 함)
            // 실제 상용 코드에서는 pthread_detach를 써서 리소스를 자동 회수하게 해야 함
            if (pthread_create(&t_id, NULL, blinkTask, (void*)id_arg) != 0) {
                printf("스레드 생성 실패!\n");
            } else {
                // 생성된 스레드를 메인 스레드와 분리 (종료 시 자동 리소스 해제)
                pthread_detach(t_id);
            }

            // 버튼 뗄 때까지 대기 & 디바운싱
            while(digitalRead(BUTTON_PIN) == HIGH) 
                delay(10);
            
            delay(50); // 추가 지연
        }
        delay(10); // CPU 점유율 낮추기
    }

    // (참고) 무한 루프라 여기 도달하진 않지만, 종료 시에는 파괴해야 함
    sem_destroy(&sem_led);
    return 0;
}