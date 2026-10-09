/*
 * ds3231_rtc.c : 실습 12-4  I2C RTC(DS3231)의 시각·온도 읽기, 시각 설정, 알람
 *
 * 회로 : DS3231 모듈 VCC -> 3.3 V (물리 핀 1)
 *                    GND -> GND (물리 핀 9)
 *                    SDA -> GPIO2/SDA1 (물리 핀 3)
 *                    SCL -> GPIO3/SCL1 (물리 핀 5)
 *        (선택) SQW -> GPIO26 (물리 핀 37): 알람 때 Low가 되는 오픈 드레인 출력
 *               ⚠ 핀 예외: BTN0(GPIO26) 버튼 배선을 뺀 뒤 연결한다. 이 프로그램은 SQW를
 *               읽지 않고 상태 레지스터의 A1F를 확인한다.
 * 준비 : I2C 켜기. i2cdetect -y 1 에 68 이 보여야 한다(UU면 커널 RTC 드라이버가 사용 중).
 * 빌드 : gcc -Wall -O2 -pthread -o ds3231_rtc ds3231_rtc.c -lpigpio -lrt
 * 실행 : sudo ./ds3231_rtc            시각과 온도를 1초마다 출력 (기본)
 *        sudo ./ds3231_rtc set        Pi의 현재 시각(NTP로 맞춰진 시스템 시계)을 RTC에 쓴다
 *        sudo ./ds3231_rtc alarm 30   매분 30초에 알람1이 울리게 하고 플래그를 감시한다
 *
 * 원본 : Linux 백서 PIGIO 탭의 DS3231 예제(i2cOpen, BCD, 온도, 알람, CSV 로깅)
 * 고친 점 : 시각 레지스터 7개를 한 번의 I2C 전송으로 읽기(따로 읽으면 초가 넘어가는
 *           순간 값이 섞일 수 있다), 영하 온도(2의 보수) 처리, 12시간제·세기 비트 처리,
 *           설정 후 OSF(발진 정지) 플래그 지우기, 요일 설정, 모의 온도(rand) 제거.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include <signal.h>
#include <pigpio.h>

#define I2C_BUS       1
#define DS3231_ADDR   0x68

/* 레지스터 주소 (DS3231 데이터시트 Figure 1. Timekeeping Registers) */
#define REG_SECONDS   0x00         /* 0x00~0x06: 초 분 시 요일 일 월 연 (BCD) */
#define REG_ALARM1    0x07         /* 0x07~0x0A: 알람1 초 분 시 일 */
#define REG_CONTROL   0x0E
#define REG_STATUS    0x0F
#define REG_TEMP_MSB  0x11         /* 0x11~0x12: 온도 (10비트 2의 보수, 0.25 °C) */

#define CTRL_INTCN    0x04         /* 1 = SQW 핀을 알람 인터럽트 출력으로 */
#define CTRL_A1IE     0x01         /* 알람1 인터럽트 허용 */
#define STAT_OSF      0x80         /* 발진기가 멈춘 적 있음 -> 시각을 믿을 수 없다 */
#define STAT_A1F      0x01         /* 알람1 발생 */

static volatile sig_atomic_t running = 1;
static int h = -1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static int bcd2dec(int bcd) { return (bcd >> 4) * 10 + (bcd & 0x0F); }
static int dec2bcd(int dec) { return ((dec / 10) << 4) | (dec % 10); }

/* 0x00~0x06 일곱 바이트를 한 번에 읽어 struct tm으로 바꾼다 */
static int rtc_read(struct tm *t)
{
    char b[7];
    int hour;

    if (i2cReadI2CBlockData((unsigned)h, REG_SECONDS, b, 7) != 7)
        return -1;

    memset(t, 0, sizeof(*t));
    t->tm_sec  = bcd2dec(b[0] & 0x7F);
    t->tm_min  = bcd2dec(b[1] & 0x7F);
    if (b[2] & 0x40) {                       /* 비트6 = 1 : 12시간제 */
        hour = bcd2dec(b[2] & 0x1F) % 12;    /* 12시 -> 0 */
        if (b[2] & 0x20)                     /* 비트5 = PM */
            hour += 12;
    } else {                                 /* 24시간제 */
        hour = bcd2dec(b[2] & 0x3F);
    }
    t->tm_hour = hour;
    t->tm_wday = (b[3] & 0x07) - 1;          /* 이 프로그램은 1 = 일요일로 쓴다 */
    t->tm_mday = bcd2dec(b[4] & 0x3F);
    t->tm_mon  = bcd2dec(b[5] & 0x1F) - 1;   /* struct tm의 월은 0~11 */
    t->tm_year = 100 + bcd2dec((unsigned char)b[6])  /* 2000년 + yy */
               + ((b[5] & 0x80) ? 100 : 0);           /* Century 비트 */
    return 0;
}

/* struct tm 값을 BCD로 바꿔 0x00~0x06에 한 번에 쓴다 (24시간제) */
static int rtc_write(const struct tm *t)
{
    char b[7];
    int status;

    b[0] = (char)dec2bcd(t->tm_sec);
    b[1] = (char)dec2bcd(t->tm_min);
    b[2] = (char)dec2bcd(t->tm_hour);        /* 비트6 = 0 : 24시간제 */
    b[3] = (char)(t->tm_wday + 1);           /* 1 = 일요일 ... 7 = 토요일 */
    b[4] = (char)dec2bcd(t->tm_mday);
    b[5] = (char)dec2bcd(t->tm_mon + 1);     /* 2000~2099년이므로 Century = 0 */
    b[6] = (char)dec2bcd(t->tm_year % 100);
    if (i2cWriteI2CBlockData((unsigned)h, REG_SECONDS, b, 7) != 0)
        return -1;

    status = i2cReadByteData((unsigned)h, REG_STATUS);   /* OSF 지우기 */
    if (status >= 0)
        i2cWriteByteData((unsigned)h, REG_STATUS, (unsigned)status & ~STAT_OSF);
    return 0;
}

/* 온도: 0x11(정수부, 부호 포함)과 0x12(상위 2비트 = 0.25 단위)를 16비트로 붙이면
   1/256 °C 단위의 2의 보수가 된다. */
static double rtc_temperature(void)
{
    char b[2];
    int16_t raw;

    if (i2cReadI2CBlockData((unsigned)h, REG_TEMP_MSB, b, 2) != 2)
        return -999.0;
    raw = (int16_t)(((unsigned char)b[0] << 8) | (unsigned char)b[1]);
    return raw / 256.0;
}

/* 알람1을 "초가 같을 때마다"(매분 한 번)로 설정한다 */
static int alarm1_every_minute(int second)
{
    char a[4];
    int ctrl;

    a[0] = (char)dec2bcd(second);            /* A1M1 = 0 : 초를 비교 */
    a[1] = (char)0x80;                       /* A1M2 = 1 : 분은 무시 */
    a[2] = (char)0x80;                       /* A1M3 = 1 : 시는 무시 */
    a[3] = (char)0x80;                       /* A1M4 = 1 : 날짜·요일은 무시 */
    if (i2cWriteI2CBlockData((unsigned)h, REG_ALARM1, a, 4) != 0)
        return -1;

    ctrl = i2cReadByteData((unsigned)h, REG_CONTROL);
    if (ctrl < 0)
        return -1;
    i2cWriteByteData((unsigned)h, REG_CONTROL, (unsigned)ctrl | CTRL_INTCN | CTRL_A1IE);
    return 0;
}

int main(int argc, char *argv[])
{
    const char *cmd = (argc > 1) ? argv[1] : "read";
    struct tm t;
    time_t now;
    char text[32];
    int status, last_sec = -1;
    static const char *wday[] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    h = i2cOpen(I2C_BUS, DS3231_ADDR, 0);
    if (h < 0) {
        fprintf(stderr, "i2cOpen(0x%02X) 실패: %d (i2cdetect에서 UU라면 커널 드라이버가 "
                        "사용 중이다)\n", DS3231_ADDR, h);
        gpioTerminate();
        return 1;
    }

    status = i2cReadByteData((unsigned)h, REG_STATUS);
    if (status < 0) {
        fprintf(stderr, "DS3231이 응답하지 않는다: 배선·전원을 확인하라\n");
        goto out;
    }
    if (status & STAT_OSF)
        printf("주의: OSF=1, 발진기가 멈춘 적이 있어 시각을 믿을 수 없다. 'set'으로 맞춰라.\n");

    if (strcmp(cmd, "set") == 0) {
        now = time(NULL);
        localtime_r(&now, &t);
        if (rtc_write(&t) == 0) {
            strftime(text, sizeof(text), "%Y-%m-%d %H:%M:%S", &t);
            printf("RTC에 시스템 시각 %s 를 썼다.\n", text);
        } else {
            fprintf(stderr, "RTC 쓰기 실패\n");
        }
    } else if (strcmp(cmd, "alarm") == 0) {
        int sec = (argc > 2) ? atoi(argv[2]) % 60 : 30;

        if (alarm1_every_minute(sec) != 0) {
            fprintf(stderr, "알람 설정 실패\n");
            goto out;
        }
        printf("알람1: 매분 %02d초. 상태 레지스터의 A1F를 0.2초마다 확인한다 (Ctrl+C로 종료)\n", sec);
        while (running) {
            status = i2cReadByteData((unsigned)h, REG_STATUS);
            if (status >= 0 && (status & STAT_A1F)) {
                if (rtc_read(&t) == 0)
                    printf("알람! %02d:%02d:%02d\n", t.tm_hour, t.tm_min, t.tm_sec);
                i2cWriteByteData((unsigned)h, REG_STATUS, (unsigned)status & ~STAT_A1F);
            }
            gpioDelay(200000);
        }
    } else {                                         /* read */
        printf("DS3231 시각과 온도 (Ctrl+C로 종료)\n");
        while (running) {
            if (rtc_read(&t) != 0) {
                fprintf(stderr, "읽기 실패\n");
                break;
            }
            if (t.tm_sec != last_sec) {              /* 초가 바뀔 때만 출력 */
                last_sec = t.tm_sec;
                printf("%04d-%02d-%02d (%s) %02d:%02d:%02d  %.2f C\n",
                       t.tm_year + 1900, t.tm_mon + 1, t.tm_mday,
                       (t.tm_wday >= 0 && t.tm_wday < 7) ? wday[t.tm_wday] : "???",
                       t.tm_hour, t.tm_min, t.tm_sec, rtc_temperature());
            }
            gpioDelay(100000);
        }
    }

out:
    i2cClose((unsigned)h);
    gpioTerminate();
    return 0;
}
