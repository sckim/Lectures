#include "DS1302.h"
#include <cstdio>
#include <unistd.h>

// 생성자
DS1302::DS1302(int rst_pin, int dat_pin, int clk_pin) 
    : _rst_pin(rst_pin), _dat_pin(dat_pin), _clk_pin(clk_pin) {
    // GPIO 초기화는 main의 gpioInitialise() 호출 이후 begin()에서 수행
}

// 소멸자
DS1302::~DS1302() {
    // 필요 시 정리 작업 (pigpio는 전역적으로 관리되므로 특별한 작업 불필요)
}

// BCD 변환 헬퍼
int DS1302::bcdToDec(int val) { return ((val / 16 * 10) + (val % 16)); }
int DS1302::decToBcd(int val) { return ((val / 10 * 16) + (val % 10)); }

// 1바이트 쓰기 (Bit-banging)
void DS1302::writeByte(unsigned char byte) {
    gpioSetMode(_dat_pin, PI_OUTPUT); 
    for (int i = 0; i < 8; i++) {
        gpioWrite(_dat_pin, (byte >> i) & 1);
        gpioDelay(1); 
        gpioWrite(_clk_pin, 1);
        gpioDelay(1);
        gpioWrite(_clk_pin, 0);
        gpioDelay(1);
    }
}

// 1바이트 읽기 (Bit-banging)
unsigned char DS1302::readByte() {
    unsigned char byte = 0;
    gpioSetMode(_dat_pin, PI_INPUT);
    gpioDelay(1); 
    for (int i = 0; i < 8; i++) {
        unsigned char bit = gpioRead(_dat_pin);
        byte |= (bit << i);
        gpioWrite(_clk_pin, 1);
        gpioDelay(1);
        gpioWrite(_clk_pin, 0);
        gpioDelay(1);
    }
    return byte;
}

// 레지스터 쓰기
void DS1302::writeReg(unsigned char reg, unsigned char data) {
    gpioWrite(_rst_pin, 1); gpioDelay(1);
    writeByte(reg);  
    writeByte(data); 
    gpioWrite(_rst_pin, 0); gpioDelay(1);
}

// 레지스터 읽기
unsigned char DS1302::readReg(unsigned char reg) {
    unsigned char data;
    gpioWrite(_rst_pin, 1); gpioDelay(1);
    writeByte(reg); 
    data = readByte(); 
    gpioWrite(_rst_pin, 0); gpioDelay(1);
    return data;
}

// 초기화
void DS1302::begin() {
    gpioWrite(_rst_pin, 0);
    gpioWrite(_clk_pin, 0);
    gpioSetMode(_rst_pin, PI_OUTPUT);
    gpioSetMode(_clk_pin, PI_OUTPUT);
    gpioSetMode(_dat_pin, PI_OUTPUT);
    
    // 쓰기 방지 해제
    writeReg(REG_WP_WR, WP_DISABLE);
}

// 시계 강제 시작 (CH 비트 클리어)
void DS1302::ensureClockRunning() {
    int sec_raw = readReg(REG_SEC_RD);
    if ((sec_raw & 0x80) != 0) {
        printf("[DS1302] Clock halted. Starting oscillator...\n");
        writeReg(REG_WP_WR, WP_DISABLE);
        writeReg(REG_SEC_WR, sec_raw & 0x7F);
        writeReg(REG_WP_WR, WP_ENABLE);
    }
}

// 시간 설정
void DS1302::setTime(int year, int month, int day, int hour, int minute, int second, int week) {
    printf("[DS1302] Setting time...\n");
    writeReg(REG_WP_WR, WP_DISABLE);
    writeReg(REG_SEC_WR,   decToBcd(second));
    writeReg(REG_MIN_WR,   decToBcd(minute));
    writeReg(REG_HOUR_WR,  decToBcd(hour));
    writeReg(REG_DAY_WR,   decToBcd(day));
    writeReg(REG_MONTH_WR, decToBcd(month));
    writeReg(REG_WEEK_WR,  decToBcd(week)); 
    writeReg(REG_YEAR_WR,  decToBcd(year % 100));
    writeReg(REG_WP_WR, WP_ENABLE);
}

// 시간 읽기
TimeData DS1302::getTime() {
    TimeData t;
    int sec_raw = readReg(REG_SEC_RD);
    t.second = bcdToDec(sec_raw & CH_MASK);
    t.minute = bcdToDec(readReg(REG_MIN_RD));
    t.hour   = bcdToDec(readReg(REG_HOUR_RD));
    t.day    = bcdToDec(readReg(REG_DAY_RD));
    t.month  = bcdToDec(readReg(REG_MONTH_RD));
    t.week   = bcdToDec(readReg(REG_WEEK_RD));
    t.year   = bcdToDec(readReg(REG_YEAR_RD)) + 2000;
    return t;
}

// 문자열로 시간 반환
std::string DS1302::getTimeString() {
    TimeData t = getTime();
    char buffer[50];
    sprintf(buffer, "%04d-%02d-%02d %02d:%02d:%02d", 
            t.year, t.month, t.day, t.hour, t.minute, t.second);
    return std::string(buffer);
}