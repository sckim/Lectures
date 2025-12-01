#include <stdio.h>
#include <unistd.h>     // sleep() 함수를 사용하기 위한 헤더
#include <pigpio.h>

// BCM 핀 번호 정의 (라즈베리파이 헤더의 22번 핀은 BCM 25번이다.)
#define GPIO_PIN 25

int main(void)
{
    // 1. 초기화 설정: 데몬을 사용하지 않도록 로컬 모드 설정
    // gpioCfgSetInternal(0) : 데몬 연결 대신 내부 초기화 사용을 설정 (필수)
    // 이 설정이 없으면 기본적으로 데몬 연결을 시도한다.
    gpioCfgSetInternals(0);

    // 2. pigpio 라이브러리 초기화 (직접 메모리 접근 시작)
    if (gpioInitialise() < 0)
    {
        fprintf(stderr, "pigpio initialization failed. Must be run with sudo.\n");
        return 1;
    }

    printf("BCM Pin %d (Header Pin 22) toggling started (Local Mode).\n", GPIO_PIN);

    // 3. 핀 모드 설정: 출력(OUTPUT)으로 설정
    gpioSetMode(GPIO_PIN, PI_OUTPUT);

    // 4. 메인 루프: 1초 간격으로 ON/OFF 반복
    while(1)
    {
        // ON (HIGH, 1) 출력
        gpioWrite(GPIO_PIN, 1);
        printf("Pin %d is HIGH (ON)\n", GPIO_PIN);
        sleep(1);  // 1초 대기

        // OFF (LOW, 0) 출력
        gpioWrite(GPIO_PIN, 0);
        printf("Pin %d is LOW (OFF)\n", GPIO_PIN);
        sleep(1);  // 1초 대기
    }

    // 5. 정리 (무한 루프이므로 사실상 도달하지 않는다)
    gpioTerminate();
    return 0;
}