#include <iostream>
#include <pigpio.h>
#include <unistd.h>
#include "DS1302.h"

// 핀 정의
#define PIN_RST 10
#define PIN_DAT 9
#define PIN_CLK 11

int main() {
    // 1. pigpio 라이브러리 초기화 (필수)
    if (gpioInitialise() < 0) {
        std::cerr << "Pigpio initialization failed!" << std::endl;
        return 1;
    }

    // 2. DS1302 객체 생성 (RST, DAT, CLK)
    DS1302 rtc(PIN_RST, PIN_DAT, PIN_CLK);

    // 3. 하드웨어 초기화
    rtc.begin();

    // 4. 시계 작동 확인 (멈춰있으면 시작)
    rtc.ensureClockRunning();

    // 5. 시간 설정 (최초 1회 실행 후 주석 처리 권장)
    // rtc.setTime(2025, 12, 1, 14, 30, 0, 1); // Year, Mon, Day, Hour, Min, Sec, Week

    std::cout << "Starting RTC Monitor..." << std::endl;

    while (true) {
        // 방법 A: 구조체로 받아서 개별 처리
        TimeData t = rtc.getTime();
        /*
        printf("Date: %04d-%02d-%02d Time: %02d:%02d:%02d\n", 
               t.year, t.month, t.day, t.hour, t.minute, t.second);
        */

        // 방법 B: 문자열로 받아서 바로 출력 (편의 함수 사용)
        std::cout << "Current Time: " << rtc.getTimeString() << std::endl;

        sleep(1);
    }

    gpioTerminate();
    return 0;
}