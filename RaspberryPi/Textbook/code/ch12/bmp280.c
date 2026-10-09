/*
 * bmp280.c : 실습 12-7 (선택)  I2C 온도·기압 센서 BMP280 읽기 (Bosch 보정식 전체 구현)
 *
 * 회로 : BMP280 모듈 VCC(VIN) -> 3.3 V (물리 핀 1)
 *                    GND      -> GND (물리 핀 9)
 *                    SDA      -> GPIO2/SDA1 (물리 핀 3)
 *                    SCL      -> GPIO3/SCL1 (물리 핀 5)
 *                    SDO      -> GND 이면 주소 0x76, 3.3 V 이면 0x77 (모듈마다 기본값이 다르다)
 *                    CSB      -> 3.3 V 또는 연결 안 함 (I2C 모드 선택; 모듈 회로도 확인)
 * 빌드 : gcc -Wall -O2 -pthread -o bmp280 bmp280.c -lpigpio -lrt
 * 실행 : sudo ./bmp280            주소 0x76, 1초마다 온도·기압 출력
 *        sudo ./bmp280 0x77       주소 지정
 *        ./bmp280 test            센서 없이 데이터시트의 계산 예(보정값·raw 값)로 보정식 확인
 *
 * 원본 : Raspberry Pi Codes 6.2의 Python smbus BMP280 예제. 원본은 보정 계수를 빅 엔디언·
 *        부호 없는 값으로 읽었고(데이터시트는 리틀 엔디언, T2·T3·P2~P9는 부호 있음),
 *        측정 모드를 켜지 않아(ctrl_meas 미설정) 센서가 sleep 상태로 남았으며,
 *        온도 계산 함수가 비어 있었다. 이를 C와 데이터시트 보정식으로 다시 작성했다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <signal.h>
#include <pigpio.h>

#define I2C_BUS          1
#define REG_CALIB        0x88      /* 0x88~0x9F : 보정 계수 24바이트 */
#define REG_ID           0xD0      /* BMP280 = 0x58 */
#define REG_RESET        0xE0      /* 0xB6을 쓰면 소프트 리셋 */
#define REG_STATUS       0xF3      /* 비트3 measuring */
#define REG_CTRL_MEAS    0xF4      /* osrs_t[7:5] osrs_p[4:2] mode[1:0] */
#define REG_CONFIG       0xF5      /* t_sb[7:5] filter[4:2] spi3w_en[0] */
#define REG_DATA         0xF7      /* 0xF7~0xFC : press(20비트) temp(20비트) */

/* 오버샘플링 온도 x1, 기압 x4, forced 모드(한 번 측정하고 sleep으로 돌아감) */
#define CTRL_MEAS_FORCED ((1 << 5) | (3 << 2) | 1)

struct bmp280_calib {
    uint16_t T1; int16_t T2, T3;
    uint16_t P1; int16_t P2, P3, P4, P5, P6, P7, P8, P9;
};

static volatile sig_atomic_t running = 1;
static int32_t t_fine;             /* 온도 보정 결과를 기압 보정에서 다시 쓴다 */

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

/* 아래 두 함수는 BMP280 데이터시트 3.11.3절의 정수 보정식을 그대로 옮긴 것이다. */

/* 온도를 0.01 °C 단위로 돌려준다. 예: 5123 = 51.23 °C */
static int32_t compensate_T(const struct bmp280_calib *c, int32_t adc_T)
{
    int32_t var1, var2;

    var1 = ((((adc_T >> 3) - ((int32_t)c->T1 << 1))) * ((int32_t)c->T2)) >> 11;
    var2 = (((((adc_T >> 4) - ((int32_t)c->T1)) * ((adc_T >> 4) - ((int32_t)c->T1))) >> 12)
            * ((int32_t)c->T3)) >> 14;
    t_fine = var1 + var2;
    return (t_fine * 5 + 128) >> 8;
}

/* 기압을 Q24.8 형식(Pa x 256)으로 돌려준다. 예: 24674867 / 256 = 96386.2 Pa */
static uint32_t compensate_P(const struct bmp280_calib *c, int32_t adc_P)
{
    int64_t var1, var2, p;

    var1 = ((int64_t)t_fine) - 128000;
    var2 = var1 * var1 * (int64_t)c->P6;
    var2 = var2 + ((var1 * (int64_t)c->P5) << 17);
    var2 = var2 + (((int64_t)c->P4) << 35);
    var1 = ((var1 * var1 * (int64_t)c->P3) >> 8) + ((var1 * (int64_t)c->P2) << 12);
    var1 = (((((int64_t)1) << 47) + var1)) * ((int64_t)c->P1) >> 33;
    if (var1 == 0)
        return 0;                  /* 0으로 나누기 방지 */
    p = 1048576 - adc_P;
    p = (((p << 31) - var2) * 3125) / var1;
    var1 = (((int64_t)c->P9) * (p >> 13) * (p >> 13)) >> 25;
    var2 = (((int64_t)c->P8) * p) >> 19;
    p = ((p + var1 + var2) >> 8) + (((int64_t)c->P7) << 4);
    return (uint32_t)p;
}

/* 리틀 엔디언 2바이트(낮은 바이트가 먼저)를 16비트로 */
static uint16_t le16(const char *b)
{
    return (uint16_t)((unsigned char)b[0] | ((unsigned char)b[1] << 8));
}

static void parse_calib(struct bmp280_calib *c, const char *b)
{
    c->T1 = le16(b + 0);
    c->T2 = (int16_t)le16(b + 2);
    c->T3 = (int16_t)le16(b + 4);
    c->P1 = le16(b + 6);
    c->P2 = (int16_t)le16(b + 8);
    c->P3 = (int16_t)le16(b + 10);
    c->P4 = (int16_t)le16(b + 12);
    c->P5 = (int16_t)le16(b + 14);
    c->P6 = (int16_t)le16(b + 16);
    c->P7 = (int16_t)le16(b + 18);
    c->P8 = (int16_t)le16(b + 20);
    c->P9 = (int16_t)le16(b + 22);
}

/* 데이터시트 3.12절 계산 예의 값으로 보정식을 확인한다 (센서 불필요) */
static int self_test(void)
{
    const struct bmp280_calib c = { 27504, 26435, -1000,
                                    36477, -10685, 3024, 2855, 140, -7, 15500, -14600, 6000 };
    int32_t T = compensate_T(&c, 519888);
    uint32_t P = compensate_P(&c, 415148);

    printf("adc_T = 519888 -> t_fine = %d, T = %d.%02d C (데이터시트: 25.08 C)\n",
           t_fine, T / 100, T % 100);
    printf("adc_P = 415148 -> P = %u/256 = %.2f Pa (데이터시트: 100653.27 Pa)\n",
           P, P / 256.0);
    return 0;
}

int main(int argc, char *argv[])
{
    unsigned addr;
    struct bmp280_calib cal;
    char b[24];
    int h, id, st, tries;
    int32_t adc_T, adc_P, T;
    uint32_t P;

    if (argc > 1 && strcmp(argv[1], "test") == 0)
        return self_test();
    addr = (argc > 1) ? (unsigned)strtol(argv[1], NULL, 0) : 0x76;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    h = i2cOpen(I2C_BUS, addr, 0);
    if (h < 0) {
        fprintf(stderr, "i2cOpen(0x%02X) 실패: %d\n", addr, h);
        gpioTerminate();
        return 1;
    }

    id = i2cReadByteData((unsigned)h, REG_ID);
    if (id == 0x58) {
        printf("BMP280 발견 (chip_id 0x58, 주소 0x%02X)\n", addr);
    } else if (id == 0x60) {
        printf("chip_id 0x60: BME280이다. 온도·기압만 읽는다(습도 레지스터는 다루지 않음).\n");
    } else {
        fprintf(stderr, "chip_id = %d (0x%02X): BMP280(0x58)이 아니다. 주소·모듈 종류를 확인하라.\n",
                id, id < 0 ? 0 : id);
        goto out;
    }

    i2cWriteByteData((unsigned)h, REG_RESET, 0xB6);        /* 소프트 리셋 */
    gpioDelay(10000);
    if (i2cReadI2CBlockData((unsigned)h, REG_CALIB, b, 24) != 24) {
        fprintf(stderr, "보정 계수 읽기 실패\n");
        goto out;
    }
    parse_calib(&cal, b);
    printf("보정 계수: T1=%u T2=%d T3=%d P1=%u P2=%d ... P9=%d\n",
           cal.T1, cal.T2, cal.T3, cal.P1, cal.P2, cal.P9);
    i2cWriteByteData((unsigned)h, REG_CONFIG, 0x00);       /* 필터 끔 */

    while (running) {
        i2cWriteByteData((unsigned)h, REG_CTRL_MEAS, CTRL_MEAS_FORCED);  /* 측정 시작 */
        tries = 0;
        do {                                               /* 측정이 끝날 때까지 */
            gpioDelay(5000);
            st = i2cReadByteData((unsigned)h, REG_STATUS);
        } while (st >= 0 && (st & 0x08) && ++tries < 20);

        if (i2cReadI2CBlockData((unsigned)h, REG_DATA, b, 6) != 6) {
            fprintf(stderr, "데이터 읽기 실패\n");
            break;
        }
        /* 20비트 값 = MSB(8) LSB(8) XLSB 상위 4비트 */
        adc_P = ((unsigned char)b[0] << 12) | ((unsigned char)b[1] << 4) | ((unsigned char)b[2] >> 4);
        adc_T = ((unsigned char)b[3] << 12) | ((unsigned char)b[4] << 4) | ((unsigned char)b[5] >> 4);
        if (adc_T == 0x80000) {                            /* 측정되지 않은 값 */
            fprintf(stderr, "측정값 없음(0x80000): 측정 모드 설정을 확인하라\n");
        } else {
            T = compensate_T(&cal, adc_T);                 /* 온도를 먼저: t_fine 계산 */
            P = compensate_P(&cal, adc_P);
            printf("T = %6.2f C   P = %8.2f hPa   (raw T=%d, P=%d)\n",
                   T / 100.0, P / 25600.0, adc_T, adc_P);
        }
        gpioDelay(1000000);
    }

out:
    i2cClose((unsigned)h);
    gpioTerminate();
    return 0;
}
