/*
 * ds1302_rtc.c : 실습 12-6  3선 직렬 RTC(DS1302)를 GPIO 비트뱅으로 읽고 쓰기
 *
 * 회로 : DS1302 모듈 VCC -> 3.3 V (물리 핀 1)   ※ 5 V에 연결하지 않는다
 *                    GND -> GND (물리 핀 34)
 *                    RST (CE)   <- GPIO12 (물리 핀 32)
 *                    CLK (SCLK) <- GPIO19 (물리 핀 35)
 *                    DAT (I/O)  <-> GPIO16 (물리 핀 36)
 *        (선택) AD2 DIO4/5/6 <- GPIO12/19/16 (CE/SCLK/IO), GND 공통
 * 빌드 : gcc -Wall -O2 -pthread -o ds1302_rtc ds1302_rtc.c -lpigpio -lrt
 * 실행 : sudo ./ds1302_rtc             시각을 1초마다 출력 (burst 읽기)
 *        sudo ./ds1302_rtc set         Pi의 시스템 시각을 DS1302에 쓴다(처음 한 번)
 *        sudo ./ds1302_rtc raw         0x81(초), 0x83(분) 명령을 한 바이트씩 보내고
 *                                      선 위의 비트 순서(LSB 먼저)를 함께 출력한다
 *
 * 원본 : Pigpio/ds1302_pigpio.c, Pigpio/DS1302_cpp (Raspberry Pi Codes 7.3.6,
 *        2025년 13주차 수업). 원본 배선은 RST=GPIO10, DAT=GPIO9, CLK=GPIO11 이었다.
 * 고친 점 : 핀을 교재 표준 핀 계획의 DS1302 전용 핀(GPIO12/19/16)으로 옮김(원본 핀은
 *           SPI0과 겹쳐 MCP3008(실습 12-5)과 함께 쓸 수 없었다),
 *           데이터시트의 CE·클록 타이밍(VCC 2.0 V 기준)을 지키는 지연, 읽기 명령의
 *           마지막 비트 뒤 DAT를 입력으로 돌린 다음 하강 에지를 만들어 버스 충돌 방지,
 *           시(hour) 레지스터의 12/24시간제 비트 처리, 시각 설정을 명령 인자로 분리,
 *           Ctrl+C 정리.
 */
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <signal.h>
#include <pigpio.h>

#define PIN_CE    12               /* CE(모듈 라벨 RST), 물리 핀 32 */
#define PIN_CLK   19               /* SCLK, 물리 핀 35 */
#define PIN_DAT   16               /* I/O,  물리 핀 36 */

/* 타이밍(us). 데이터시트 AC 특성의 VCC = 2.0 V 값(가장 느린 조건)을 넉넉히 지킨다. */
#define T_CC      4                /* CE High -> 첫 클록까지 (tCC 4 us) */
#define T_CWH     4                /* CE Low 유지 시간 (tCWH 4 us) */
#define T_HALF    2                /* 클록 High/Low 각각 (tCH, tCL 1 us 이상) */

/* 명령 바이트 = 1 | RAM/CK | A4~A0 | RD/W. 짝수 = 쓰기, 홀수(+1) = 읽기 */
#define CMD_SEC       0x80
#define CMD_MIN       0x82
#define CMD_HOUR      0x84
#define CMD_DATE      0x86
#define CMD_MONTH     0x88
#define CMD_DAY       0x8A
#define CMD_YEAR      0x8C
#define CMD_WP        0x8E         /* 쓰기 방지(Write Protect) 레지스터 */
#define CMD_BURST     0xBE         /* 클록 burst: 위 8개를 한 번에 */
#define READ          0x01         /* 명령의 비트0 = 1 이면 읽기 */

#define SEC_CH        0x80         /* 초 레지스터 비트7 = Clock Halt (1이면 멈춤) */
#define WP_ON         0x80

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static int bcd2dec(int bcd) { return (bcd >> 4) * 10 + (bcd & 0x0F); }
static int dec2bcd(int dec) { return ((dec / 10) << 4) | (dec % 10); }

/* 한 바이트를 LSB부터 내보낸다. DS1302는 SCLK 상승 에지에서 I/O를 읽는다.
   last_is_read_cmd가 1이면 마지막 상승 에지 뒤에 DAT를 입력으로 돌려 놓고
   하강 에지를 만든다. 그 하강 에지에서 DS1302가 첫 데이터 비트를 내보내기 때문이다. */
static void ds_write_byte(unsigned byte, int last_is_read_cmd)
{
    int i;

    gpioSetMode(PIN_DAT, PI_OUTPUT);
    for (i = 0; i < 8; i++) {
        gpioWrite(PIN_DAT, (byte >> i) & 1);     /* LSB 먼저 */
        gpioDelay(T_HALF);
        gpioWrite(PIN_CLK, 1);                   /* 상승 에지: DS1302가 읽음 */
        gpioDelay(T_HALF);
        if (i == 7 && last_is_read_cmd)
            gpioSetMode(PIN_DAT, PI_INPUT);      /* 칩이 말할 차례 -> 손을 뗀다 */
        gpioWrite(PIN_CLK, 0);
    }
}

/* 한 바이트를 LSB부터 읽는다. 데이터는 SCLK 하강 에지 뒤에 나와 있다. */
static unsigned ds_read_byte(void)
{
    unsigned byte = 0;
    int i;

    gpioSetMode(PIN_DAT, PI_INPUT);
    for (i = 0; i < 8; i++) {
        gpioDelay(T_HALF);
        byte |= (unsigned)gpioRead(PIN_DAT) << i;
        gpioWrite(PIN_CLK, 1);
        gpioDelay(T_HALF);
        gpioWrite(PIN_CLK, 0);                   /* 하강 에지: 다음 비트가 나온다 */
    }
    return byte;
}

static void ce_begin(void)
{
    gpioWrite(PIN_CLK, 0);                       /* CE를 올리기 전 SCLK는 Low */
    gpioWrite(PIN_CE, 1);
    gpioDelay(T_CC);
}

static void ce_end(void)
{
    gpioWrite(PIN_CE, 0);                        /* CE Low = 전송 끝, I/O는 고임피던스 */
    gpioSetMode(PIN_DAT, PI_INPUT);
    gpioDelay(T_CWH);
}

static void ds_write_reg(unsigned cmd, unsigned value)
{
    ce_begin();
    ds_write_byte(cmd, 0);
    ds_write_byte(value, 0);
    ce_end();
}

static unsigned ds_read_reg(unsigned cmd)
{
    unsigned v;

    ce_begin();
    ds_write_byte(cmd | READ, 1);
    v = ds_read_byte();
    ce_end();
    return v;
}

/* 클록 burst 읽기: 초, 분, 시, 일, 월, 요일, 연, WP 8바이트를 한 번의 CE 구간에 */
static void ds_read_clock(unsigned b[8])
{
    int i;

    ce_begin();
    ds_write_byte(CMD_BURST | READ, 1);
    for (i = 0; i < 8; i++)
        b[i] = ds_read_byte();
    ce_end();
}

static int hour_from_reg(unsigned r)
{
    int hour;

    if (r & 0x80) {                              /* 비트7 = 1 : 12시간제 */
        hour = bcd2dec(r & 0x1F) % 12;
        if (r & 0x20)                            /* 비트5 = PM */
            hour += 12;
        return hour;
    }
    return bcd2dec(r & 0x3F);                    /* 24시간제 */
}

static void set_from_system(void)
{
    time_t now = time(NULL);
    struct tm t;

    localtime_r(&now, &t);
    ds_write_reg(CMD_WP, 0x00);                  /* 1. 쓰기 방지 해제 */
    ds_write_reg(CMD_SEC, dec2bcd(t.tm_sec));    /* 2. CH = 0 -> 발진 시작 */
    ds_write_reg(CMD_MIN, dec2bcd(t.tm_min));
    ds_write_reg(CMD_HOUR, dec2bcd(t.tm_hour));  /*    비트7 = 0 : 24시간제 */
    ds_write_reg(CMD_DATE, dec2bcd(t.tm_mday));
    ds_write_reg(CMD_MONTH, dec2bcd(t.tm_mon + 1));
    ds_write_reg(CMD_DAY, (unsigned)t.tm_wday + 1);   /* 1 = 일요일로 정함 */
    ds_write_reg(CMD_YEAR, dec2bcd(t.tm_year % 100));
    ds_write_reg(CMD_WP, WP_ON);                 /* 3. 쓰기 방지 다시 켬 */
    printf("DS1302에 %04d-%02d-%02d %02d:%02d:%02d 를 썼다.\n",
           t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec);
}

static void print_wire_order(const char *name, unsigned byte)
{
    int i;

    printf("%s 0x%02X : MSB->LSB ", name, byte);
    for (i = 7; i >= 0; i--)
        printf("%u", (byte >> i) & 1);
    printf("  / 선 위 순서(LSB 먼저) ");
    for (i = 0; i < 8; i++)
        printf("%u", (byte >> i) & 1);
    printf("\n");
}

int main(int argc, char *argv[])
{
    const char *cmd = (argc > 1) ? argv[1] : "read";
    unsigned b[8];
    int last_sec = -1;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    gpioWrite(PIN_CE, 0);                        /* 핀을 출력으로 바꾸기 전에 Low로 */
    gpioWrite(PIN_CLK, 0);
    gpioSetMode(PIN_CE, PI_OUTPUT);
    gpioSetMode(PIN_CLK, PI_OUTPUT);
    gpioSetMode(PIN_DAT, PI_INPUT);
    gpioDelay(T_CWH);

    if (strcmp(cmd, "set") == 0) {
        set_from_system();
    } else if (strcmp(cmd, "raw") == 0) {
        unsigned sec = ds_read_reg(CMD_SEC), min = ds_read_reg(CMD_MIN);

        print_wire_order("명령(초 읽기)", CMD_SEC | READ);
        print_wire_order("응답(초)     ", sec);
        print_wire_order("명령(분 읽기)", CMD_MIN | READ);
        print_wire_order("응답(분)     ", min);
        printf("=> %02d분 %02d초 (CH=%u)\n", bcd2dec(min & 0x7F), bcd2dec(sec & 0x7F),
               (sec & SEC_CH) ? 1 : 0);
    } else {
        ds_read_clock(b);
        if (b[0] & SEC_CH)
            printf("주의: CH=1, 시계가 멈춰 있다. 'sudo ./ds1302_rtc set'으로 시각을 쓰면 시작한다.\n");
        printf("DS1302 시각 (Ctrl+C로 종료)\n");
        while (running) {
            ds_read_clock(b);
            if (bcd2dec(b[0] & 0x7F) != last_sec) {
                last_sec = bcd2dec(b[0] & 0x7F);
                printf("20%02d-%02d-%02d (요일 %u) %02d:%02d:%02d  WP=%u\n",
                       bcd2dec(b[6]), bcd2dec(b[4] & 0x1F), bcd2dec(b[3] & 0x3F),
                       b[5] & 0x07, hour_from_reg(b[2]), bcd2dec(b[1] & 0x7F),
                       last_sec, (b[7] & WP_ON) ? 1 : 0);
            }
            gpioDelay(200000);
        }
    }

    gpioWrite(PIN_CE, 0);
    gpioSetMode(PIN_CE, PI_INPUT);
    gpioSetMode(PIN_CLK, PI_INPUT);
    gpioSetMode(PIN_DAT, PI_INPUT);
    gpioTerminate();
    return 0;
}
