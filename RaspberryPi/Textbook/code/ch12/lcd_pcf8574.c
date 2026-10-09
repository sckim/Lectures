/*
 * lcd_pcf8574.c : 실습 12-3  PCF8574 I2C 백팩이 달린 16x2 문자 LCD에 글자와 시각 표시
 *
 * 회로 : 양방향 레벨 시프터(BSS138 4채널 모듈) 경유 = 표준 배선 (12.4.4절)
 *          Pi 3.3 V (물리 핀 1)  -> 시프터 LV
 *          Pi 5 V   (물리 핀 2)  -> 시프터 HV, LCD 모듈 VCC
 *          Pi GND   (물리 핀 6)  -> 시프터 GND(양쪽 공통), LCD 모듈 GND
 *          GPIO2/SDA1 (물리 핀 3) <-> LV1 | HV1 <-> LCD 모듈 SDA
 *          GPIO3/SCL1 (물리 핀 5) <-> LV2 | HV2 <-> LCD 모듈 SCL
 *        ※ 5 V로 켠 모듈의 SDA/SCL을 Pi에 바로 연결하지 않는다(모듈 풀업이 5 V).
 *          대안: 모듈 VCC를 3.3 V로 켜면 시프터 없이 직결한다(글자가 흐릴 수 있다).
 * 준비 : sudo raspi-config 에서 I2C 켜기, sudo i2cdetect -y 1 로 주소 확인(0x27 또는 0x3F)
 * 빌드 : gcc -Wall -O2 -pthread -o lcd_pcf8574 lcd_pcf8574.c -lpigpio -lrt
 * 실행 : sudo ./lcd_pcf8574                       주소 0x27, 날짜·시각을 1초마다 표시
 *        sudo ./lcd_pcf8574 0x3F                  주소 지정
 *        sudo ./lcd_pcf8574 0x27 "Hello, Pi 4!" "pigpio + I2C"   두 줄 문자열 표시
 *        Ctrl+C로 끝내면 화면을 지우고 백라이트를 끈다.
 *
 * 원본 : Pigpio/lcd_pcf8574.c (Raspberry Pi Codes 7.3.6, 2025년 13주차 수업)
 * 고친 점 : 전원 인가 후 대기와 초기화 단계별 대기(HD44780 데이터시트 4비트 초기화 절차),
 *           16칸을 넘는 문자열 자르기, 주소·문자열 인자, Ctrl+C 정리, 오류 검사.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <signal.h>
#include <pigpio.h>

#define I2C_BUS    1
#define LCD_COLS   16

/* PCF8574 출력 비트(P0~P7)와 LCD 핀의 연결. 흔한 백팩 기준이며 모듈마다 다를 수 있다. */
#define LCD_RS     0x01            /* P0: 0 = 명령, 1 = 문자 데이터 */
#define LCD_RW     0x02            /* P1: 0 = 쓰기 (이 예제는 쓰기만 한다) */
#define LCD_EN     0x04            /* P2: Enable, High -> Low 에서 LCD가 값을 읽는다 */
#define LCD_BL     0x08            /* P3: 백라이트 트랜지스터 */
                                   /* P4~P7: LCD D4~D7 (4비트 데이터) */

static volatile sig_atomic_t running = 1;
static int handle = -1;
static unsigned backlight = LCD_BL;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* PCF8574의 8개 출력 핀을 한 번에 정한다 = I2C로 1바이트 쓰기 */
static void pcf_write(unsigned bits)
{
    if (i2cWriteByte((unsigned)handle, bits | backlight) != 0)
        fprintf(stderr, "I2C 쓰기 실패(NACK?): 배선과 주소를 확인하라\n");
}

/* 상위 니블(4비트)을 D4~D7에 올리고 EN을 High -> Low로 흔들어 LCD가 읽게 한다 */
static void lcd_write4(unsigned nibble_hi, unsigned rs)
{
    unsigned bits = (nibble_hi & 0xF0) | rs;

    pcf_write(bits);               /* 데이터 먼저 안정시키고 */
    pcf_write(bits | LCD_EN);      /* EN High */
    gpioDelay(1);
    pcf_write(bits);               /* EN Low: 이 하강 에지에서 래치 */
    gpioDelay(50);                 /* 일반 명령 실행 시간(37 us)보다 넉넉히 */
}

/* 8비트 값을 상위 4비트, 하위 4비트 순서로 두 번 보낸다 */
static void lcd_send(unsigned value, unsigned rs)
{
    lcd_write4(value & 0xF0, rs);
    lcd_write4((value << 4) & 0xF0, rs);
}

static void lcd_command(unsigned cmd)
{
    lcd_send(cmd, 0);
    if (cmd == 0x01 || cmd == 0x02)  /* Clear, Return home은 1.52 ms 걸린다 */
        gpioDelay(2000);
}

static void lcd_init(void)
{
    gpioDelay(50000);              /* 전원이 들어온 뒤 40 ms 이상 기다린다 */
    /* LCD가 지금 8비트 모드인지 4비트 모드인지 모르므로, "8비트로 설정" 명령의
       상위 니블(0x3)을 세 번 보내 확실히 8비트 상태로 맞춘 뒤 4비트로 바꾼다. */
    lcd_write4(0x30, 0);
    gpioDelay(4500);               /* 4.1 ms 이상 */
    lcd_write4(0x30, 0);
    gpioDelay(150);                /* 100 us 이상 */
    lcd_write4(0x30, 0);
    gpioDelay(150);
    lcd_write4(0x20, 0);           /* 이제부터 4비트 모드 */
    gpioDelay(150);

    lcd_command(0x28);             /* Function set: 4비트, 2줄, 5x8 글꼴 */
    lcd_command(0x08);             /* Display off */
    lcd_command(0x01);             /* Clear display */
    lcd_command(0x06);             /* Entry mode: 쓰면 커서가 오른쪽으로 */
    lcd_command(0x0C);             /* Display on, 커서 끔, 깜빡임 끔 */
}

static void lcd_set_cursor(int row, int col)
{
    lcd_command(0x80 | ((row ? 0x40 : 0x00) + col));   /* DDRAM 주소 설정 */
}

/* 한 줄을 출력한다. 16칸보다 길면 자르고, 짧으면 공백으로 채워 이전 글자를 지운다. */
static void lcd_print_line(int row, const char *s)
{
    int i;

    lcd_set_cursor(row, 0);
    for (i = 0; i < LCD_COLS; i++)
        lcd_send(*s ? (unsigned char)*s++ : ' ', LCD_RS);
}

int main(int argc, char *argv[])
{
    unsigned addr = (argc > 1) ? (unsigned)strtol(argv[1], NULL, 0) : 0x27;
    char line0[LCD_COLS + 1], line1[LCD_COLS + 1];
    time_t now, last = 0;
    struct tm *t;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    handle = i2cOpen(I2C_BUS, addr, 0);
    if (handle < 0) {
        fprintf(stderr, "i2cOpen(%d, 0x%02X) 실패: %d\n", I2C_BUS, addr, handle);
        gpioTerminate();
        return 1;
    }
    if (i2cReadByte((unsigned)handle) < 0) {        /* 장치가 대답하는지 먼저 확인 */
        fprintf(stderr, "0x%02X 에서 응답이 없다. i2cdetect -y 1 로 주소를 확인하라.\n", addr);
        i2cClose((unsigned)handle);
        gpioTerminate();
        return 1;
    }

    printf("LCD 초기화 (I2C bus %d, 주소 0x%02X)\n", I2C_BUS, addr);
    lcd_init();

    if (argc > 2) {                                  /* 문자열 모드 */
        lcd_print_line(0, argv[2]);
        lcd_print_line(1, argc > 3 ? argv[3] : "");
        printf("문자열을 표시했다. Ctrl+C로 종료\n");
        while (running)
            gpioDelay(100000);
    } else {                                         /* 시계 모드 */
        printf("날짜와 시각을 1초마다 표시한다. Ctrl+C로 종료\n");
        while (running) {
            now = time(NULL);
            if (now != last) {                       /* 초가 바뀔 때만 다시 쓴다 */
                last = now;
                t = localtime(&now);
                strftime(line0, sizeof(line0), "%Y-%m-%d %a", t);
                strftime(line1, sizeof(line1), "%H:%M:%S", t);
                lcd_print_line(0, line0);
                lcd_print_line(1, line1);
            }
            gpioDelay(100000);                       /* 0.1 s마다 확인 */
        }
    }

    lcd_command(0x01);             /* 화면 지우기 */
    backlight = 0;                 /* 백라이트 끄기 */
    pcf_write(0x00);
    i2cClose((unsigned)handle);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
