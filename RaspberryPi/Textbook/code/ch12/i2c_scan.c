/*
 * i2c_scan.c : 실습 12-3  i2cdetect가 하는 일을 pigpio로 직접 해 보기
 *
 * 주소 0x03~0x77에 차례로 "주소 + R/W" 한 바이트만 보내 ACK가 오는지 본다.
 * i2cdetect와 같이 대부분의 주소는 quick write(R/W=0)로, EEPROM이 많이 쓰는
 * 0x30~0x37, 0x50~0x5F는 receive byte(R/W=1)로 확인한다.
 *
 * 회로 : I2C 장치 SDA -> GPIO2/SDA1 (물리 핀 3), SCL -> GPIO3/SCL1 (물리 핀 5),
 *        GND -> GND (물리 핀 6). VCC는 본문 12.4절의 전압 확인을 먼저 한다.
 * 준비 : sudo raspi-config 에서 I2C 켜기 (dtparam=i2c_arm=on), 재부팅
 * 빌드 : gcc -Wall -O2 -pthread -o i2c_scan i2c_scan.c -lpigpio -lrt
 * 실행 : sudo ./i2c_scan          (버스 1)
 */
#include <stdio.h>
#include <stdlib.h>
#include <pigpio.h>

int main(int argc, char *argv[])
{
    unsigned bus = (argc > 1) ? (unsigned)atoi(argv[1]) : 1;
    unsigned addr;
    int h, r, found = 0;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }

    printf("     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f\n");
    for (addr = 0; addr < 0x80; addr++) {
        if (addr % 16 == 0)
            printf("%02x:", addr);

        if (addr < 0x03 || addr > 0x77) {        /* 예약된 주소는 건너뛴다 */
            printf("   ");
        } else {
            h = i2cOpen(bus, addr, 0);
            if (h == PI_BAD_I2C_BUS) {           /* /dev/i2c-N 자체가 없다 */
                printf("\n/dev/i2c-%u 를 열 수 없다: I2C가 꺼져 있다.\n", bus);
                gpioTerminate();
                return 1;
            }
            if (h < 0) {
                printf(" UU");                   /* 커널 드라이버가 쓰는 중 등 */
            } else {
                if ((addr >= 0x30 && addr <= 0x37) || (addr >= 0x50 && addr <= 0x5F))
                    r = i2cReadByte((unsigned)h);         /* 주소 + R, 1바이트 읽기 */
                else
                    r = i2cWriteQuick((unsigned)h, 0);    /* 주소 + W 뿐 */
                if (r >= 0) {
                    printf(" %02x", addr);       /* ACK가 왔다 = 장치가 있다 */
                    found++;
                } else {
                    printf(" --");               /* NACK */
                }
                i2cClose((unsigned)h);
            }
        }
        if (addr % 16 == 15)
            printf("\n");
    }
    printf("응답한 장치: %d개\n", found);

    gpioTerminate();
    return 0;
}
