/*
 * Project: RPi 4 I2C LCD Control using pigpio
 * Author: Embedded System Expert
 * Date: 2024
 * Hardware: Raspberry Pi 4 Model B, PCF8574 I2C Backpack + 16x2 LCD
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pigpio.h>

// I2C 설정
#define I2C_BUS 1
#define I2C_ADDR 0x27 // i2cdetect로 확인된 주소로 변경 필요

// PCF8574 비트 마스크 정의
// P0: RS, P1: RW, P2: EN, P3: Backlight, P4-P7: Data
#define LCD_RS 0x01 // 0: Command, 1: Data
#define LCD_RW 0x02 // 0: Write, 1: Read (거의 쓰지 않음)
#define LCD_EN 0x04 // Enable Bit
#define LCD_BL 0x08 // Backlight Bit (켜려면 항상 1 유지)

int handle; // I2C 핸들

// I2C로 바이트 전송
void i2c_write_byte(unsigned char val) {
    i2cWriteByte(handle, val | LCD_BL); // 백라이트 상태 유지하며 전송
}

// Enable 핀 펄스 발생 (데이터 래치)
void lcd_toggle_enable(unsigned char val) {
    usleep(500); // 지연
    i2c_write_byte(val | LCD_EN); // Enable High
    usleep(500);
    i2c_write_byte(val & ~LCD_EN); // Enable Low
    usleep(500);
}

// 4비트 모드로 데이터/명령어 전송
// mode: 0 (Command), 1 (Data)
void lcd_send_byte(unsigned char val, int mode) {
    unsigned char high_nibble = val & 0xF0;
    unsigned char low_nibble = (val << 4) & 0xF0;
    unsigned char rs_bit = mode ? LCD_RS : 0x00;

    // 상위 4비트 전송
    i2c_write_byte(high_nibble | rs_bit | LCD_BL);
    lcd_toggle_enable(high_nibble | rs_bit | LCD_BL);

    // 하위 4비트 전송
    i2c_write_byte(low_nibble | rs_bit | LCD_BL);
    lcd_toggle_enable(low_nibble | rs_bit | LCD_BL);
}

void lcd_clear() {
    lcd_send_byte(0x01, 0);
    usleep(2000); // Clear 명령은 시간이 좀 더 필요함
}

// LCD 초기화 (4비트 모드 설정 시퀀스 중요)
void lcd_init() {
    // 1. 초기화 시퀀스 시작 (전원 인가 후 대기 필요하지만 pigpio init에서 커버됨)
    
    // 2. 0x03을 3번 보내어 8비트 모드에서 확실히 빠져나오도록 유도 (매뉴얼 기준)
    lcd_send_byte(0x33, 0); 
    lcd_send_byte(0x32, 0); // 4비트 모드 진입 명령

    // 3. 기능 설정: 4비트, 2라인, 5x8 폰트
    lcd_send_byte(0x28, 0);
    
    // 4. Display Control: 화면 켬, 커서 끔, 블링크 끔
    lcd_send_byte(0x0C, 0);
    
    // 5. Entry Mode: 글자 입력 시 커서 우측 이동
    lcd_send_byte(0x06, 0);
    
    lcd_clear();
}

// 문자열 출력 함수
void lcd_print(const char *str) {
    while (*str) {
        lcd_send_byte(*(str++), 1);
    }
}

// 커서 위치 이동 (line: 0 or 1)
void lcd_set_cursor(int line, int col) {
    int pos = (line == 0) ? 0x80 + col : 0xC0 + col;
    lcd_send_byte(pos, 0);
}

int main(int argc, char *argv[]) {
    // 1. pigpio 라이브러리 초기화
    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio initialization failed\n");
        return 1;
    }

    // 2. I2C 디바이스 열기
    handle = i2cOpen(I2C_BUS, I2C_ADDR, 0);
    if (handle < 0) {
        fprintf(stderr, "Failed to open I2C device. Check address and connection.\n");
        gpioTerminate();
        return 1;
    }

    printf("LCD Initializing...\n");
    lcd_init();

    // 3. 테스트 출력
    lcd_set_cursor(0, 0);
    lcd_print("Hello, Pi 4!");
    
    lcd_set_cursor(1, 0);
    lcd_print("pigpio & C Code");

    printf("Text displayed. Press Ctrl+C to exit.\n");

    // 데모용으로 유지하다가 종료 (실제 어플리케이션에서는 루프 등 활용)
    sleep(10);

    // 4. 종료 처리
    lcd_clear();
    // 백라이트 끄기 (선택사항)
    i2cWriteByte(handle, 0x00); 
    
    i2cClose(handle);
    gpioTerminate();

    return 0;
}