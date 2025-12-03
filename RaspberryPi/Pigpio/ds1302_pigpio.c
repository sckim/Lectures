/*
 * Project: DS1302 Control with Raspberry Pi 4 using pigpio (Refactored)
 * Author: Embedded Systems Expert
 * Description: Refactored for better readability using #define macros.
 */

#include <stdio.h>
#include <stdlib.h>
#include <pigpio.h>
#include <unistd.h>

// --- PIN DEFINITIONS (BCM Numbering) ---
#define PIN_RST 10 // CE (Chip Enable)
#define PIN_DAT 9  // I/O (Data)
#define PIN_CLK 11 // SCLK (Clock)

// --- DS1302 REGISTER DEFINITIONS ---
// Write Registers (Even numbers)
#define REG_SEC_WR   0x80
#define REG_MIN_WR   0x82
#define REG_HOUR_WR  0x84
#define REG_DAY_WR   0x86
#define REG_MONTH_WR 0x88
#define REG_WEEK_WR  0x8A
#define REG_YEAR_WR  0x8C
#define REG_WP_WR    0x8E // Write Protection

// Read Registers (Odd numbers: Write Address + 1)
#define REG_SEC_RD   0x81
#define REG_MIN_RD   0x83
#define REG_HOUR_RD  0x85
#define REG_DAY_RD   0x87
#define REG_MONTH_RD 0x89
#define REG_WEEK_RD  0x8B
#define REG_YEAR_RD  0x8D
#define REG_WP_RD    0x8F

// --- CONSTANTS ---
#define WP_ENABLE    0x80 // Write Protect ON
#define WP_DISABLE   0x00 // Write Protect OFF
#define CH_MASK      0x7F // Clock Halt Mask (to remove the MSB)

// --- HELPER FUNCTIONS ---

int bcdToDec(int val) {
    return ((val / 16 * 10) + (val % 16));
}

int decToBcd(int val) {
    return ((val / 10 * 16) + (val % 10));
}

void ds1302_write_byte(unsigned char byte) {
    gpioSetMode(PIN_DAT, PI_OUTPUT); 

    for (int i = 0; i < 8; i++) {
        gpioWrite(PIN_DAT, (byte >> i) & 1);
        gpioDelay(1); 

        gpioWrite(PIN_CLK, 1);
        gpioDelay(1);
        gpioWrite(PIN_CLK, 0);
        gpioDelay(1);
    }
}

unsigned char ds1302_read_byte() {
    unsigned char byte = 0;
    
    gpioSetMode(PIN_DAT, PI_INPUT);
    gpioDelay(1); 

    for (int i = 0; i < 8; i++) {
        unsigned char bit = gpioRead(PIN_DAT);
        byte |= (bit << i);

        gpioWrite(PIN_CLK, 1);
        gpioDelay(1);
        gpioWrite(PIN_CLK, 0);
        gpioDelay(1);
    }
    return byte;
}

void ds1302_write_reg(unsigned char reg, unsigned char data) {
    gpioWrite(PIN_RST, 1); 
    gpioDelay(1);

    ds1302_write_byte(reg);  
    ds1302_write_byte(data); 

    gpioWrite(PIN_RST, 0); 
    gpioDelay(1);
}

unsigned char ds1302_read_reg(unsigned char reg) {
    unsigned char data;
    
    gpioWrite(PIN_RST, 1); 
    gpioDelay(1);

    ds1302_write_byte(reg); 
    data = ds1302_read_byte(); 

    gpioWrite(PIN_RST, 0); 
    gpioDelay(1);

    return data;
}

// --- MAIN FUNCTIONS ---

void ds1302_init() {
    gpioWrite(PIN_RST, 0);
    gpioWrite(PIN_CLK, 0);
    gpioSetMode(PIN_RST, PI_OUTPUT);
    gpioSetMode(PIN_CLK, PI_OUTPUT);
    gpioSetMode(PIN_DAT, PI_OUTPUT);
    
    // Disable Write Protection initially
    ds1302_write_reg(REG_WP_WR, WP_DISABLE);
}

void set_time(int sec, int min, int hour, int day, int month, int week, int year) {
    printf("[INFO] Setting time to %04d-%02d-%02d %02d:%02d:%02d...\n", year, month, day, hour, min, sec);
    
    // 1. 쓰기 방지 해제
    ds1302_write_reg(REG_WP_WR, WP_DISABLE);

    // 2. 시간 데이터 쓰기 (가독성이 훨씬 좋아졌습니다)
    ds1302_write_reg(REG_SEC_WR,   decToBcd(sec));
    ds1302_write_reg(REG_MIN_WR,   decToBcd(min));
    ds1302_write_reg(REG_HOUR_WR,  decToBcd(hour));
    ds1302_write_reg(REG_DAY_WR,   decToBcd(day));
    ds1302_write_reg(REG_MONTH_WR, decToBcd(month));
    ds1302_write_reg(REG_WEEK_WR,  decToBcd(week)); 
    ds1302_write_reg(REG_YEAR_WR,  decToBcd(year % 100));

    // 3. 쓰기 방지 설정
    ds1302_write_reg(REG_WP_WR, WP_ENABLE);
}

void get_time() {
    // 1. 시간 데이터 읽기 (어떤 레지스터를 읽는지 명확합니다)
    int sec_raw = ds1302_read_reg(REG_SEC_RD);
    int sec  = bcdToDec(sec_raw & CH_MASK); // 0x7F 마스크 상수 사용
    
    int min  = bcdToDec(ds1302_read_reg(REG_MIN_RD));
    int hour = bcdToDec(ds1302_read_reg(REG_HOUR_RD));
    int day  = bcdToDec(ds1302_read_reg(REG_DAY_RD));
    int month = bcdToDec(ds1302_read_reg(REG_MONTH_RD));
    int week = bcdToDec(ds1302_read_reg(REG_WEEK_RD));
    int year = bcdToDec(ds1302_read_reg(REG_YEAR_RD)) + 2000;

    printf("Current Time: %04d-%02d-%02d (Day: %d) %02d:%02d:%02d\n", 
           year, month, day, week, hour, min, sec);
}

// 시계가 멈춰있다면 강제로 시작시키는 함수
void ensure_clock_running() {
    // 1. 현재 초(Seconds) 값을 읽어옵니다.
    int sec_raw = ds1302_read_reg(REG_SEC_RD);
    
    // 2. 최상위 비트(8번째 비트, 0x80)가 1이면 시계가 멈춘 상태(Clock Halt)입니다.
    if ((sec_raw & 0x80) != 0) {
        printf("[WARNING] Clock is HALTED. Attempting to start oscillator...\n");
        
        // 3. 쓰기 방지 해제
        ds1302_write_reg(REG_WP_WR, WP_DISABLE);
        
        // 4. 최상위 비트를 0으로 만든 값(0x7F와 AND 연산)을 다시 씀 -> 시계 시작(Start)
        ds1302_write_reg(REG_SEC_WR, sec_raw & 0x7F);
        
        // 5. 쓰기 방지 재설정
        ds1302_write_reg(REG_WP_WR, WP_ENABLE);
        
        printf("[INFO] Oscillator started.\n");
    } else {
        printf("[INFO] Clock is already running.\n");
    }
}

int main() {
    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio initialisation failed\n");
        return 1;
    }

    ds1302_init();

    // [핵심] 시계가 멈춰있으면 깨웁니다.
    // ensure_clock_running();

    // [설정 시 주석 해제]
    // set_time(0, 57, 16, 3, 12, 1, 2025); 

    printf("Starting DS1302 Read Loop...\n");
    while (1) {
        get_time();
        sleep(1);
    }

    gpioTerminate();
    return 0;
}