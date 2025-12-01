#ifndef DS1302_H
#define DS1302_H

#include <string>
#include <pigpio.h>

// 시간 정보를 담을 구조체
struct TimeData {
    int year;
    int month;
    int day;
    int week; // 1=Sunday, 7=Saturday
    int hour;
    int minute;
    int second;
};

class DS1302 {
public:
    // 생성자: 핀 번호를 설정합니다.
    DS1302(int rst_pin, int dat_pin, int clk_pin);
    
    // 소멸자
    ~DS1302();

    // 초기화 및 작동 확인
    void begin();
    void ensureClockRunning(); // 시계가 멈춰있으면 강제로 시작

    // 시간 설정 및 읽기
    void setTime(int year, int month, int day, int hour, int minute, int second, int week);
    TimeData getTime();
    
    // 유틸리티
    std::string getTimeString(); // 현재 시간을 문자열로 반환

private:
    // 핀 번호 멤버 변수
    int _rst_pin;
    int _dat_pin;
    int _clk_pin;

    // 레지스터 상수
    static const int REG_SEC_WR   = 0x80;
    static const int REG_MIN_WR   = 0x82;
    static const int REG_HOUR_WR  = 0x84;
    static const int REG_DAY_WR   = 0x86;
    static const int REG_MONTH_WR = 0x88;
    static const int REG_WEEK_WR  = 0x8A;
    static const int REG_YEAR_WR  = 0x8C;
    static const int REG_WP_WR    = 0x8E;

    static const int REG_SEC_RD   = 0x81;
    static const int REG_MIN_RD   = 0x83;
    static const int REG_HOUR_RD  = 0x85;
    static const int REG_DAY_RD   = 0x87;
    static const int REG_MONTH_RD = 0x89;
    static const int REG_WEEK_RD  = 0x8B;
    static const int REG_YEAR_RD  = 0x8D;
    static const int REG_WP_RD    = 0x8F;

    static const int WP_ENABLE    = 0x80;
    static const int WP_DISABLE   = 0x00;
    static const int CH_MASK      = 0x7F;

    // 내부 헬퍼 함수
    int bcdToDec(int val);
    int decToBcd(int val);
    void writeByte(unsigned char byte);
    unsigned char readByte();
    void writeReg(unsigned char reg, unsigned char data);
    unsigned char readReg(unsigned char reg);
};

#endif // DS1302_H