/*
 * i2c_probe.c : 실습 10-6  PCF8574에 0x00, 0x01, 0x02를 보내 I2C 파형을 관찰한다
 *
 * 13주차 수업의 "관찰용 코드"를 독립 프로그램으로 만든 것이다. 같은 세 바이트를
 * 2초마다 반복해 보내므로, 로직 분석기 트리거(SCL 하강 에지)가 매번 같은 장면을 잡는다.
 *
 * 회로 : Pi GPIO2/SDA1 (물리 핀 3) -> PCF8574 SDA, 같은 선에서 분기 -> AD2 DIO 15
 *        Pi GPIO3/SCL1 (물리 핀 5) -> PCF8574 SCL, 같은 선에서 분기 -> AD2 DIO 14
 *        Pi GND (물리 핀 6)         -> PCF8574 GND, AD2 GND
 *        PCF8574 VCC: 모듈 풀업이 Pi 쪽으로 몇 V를 거는지 먼저 확인한다(본문 참고).
 * 준비 : sudo raspi-config 에서 I2C 켜기, sudo i2cdetect -y 1 로 주소 확인
 * 빌드 : gcc -Wall -O2 -pthread -o i2c_probe i2c_probe.c -lpigpio -lrt
 * 실행 : sudo ./i2c_probe          (주소 0x27)
 *        sudo ./i2c_probe 0x20     (i2cdetect에서 본 주소)
 */
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <pigpio.h>

#define I2C_BUS 1              /* /dev/i2c-1 = GPIO2/3 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(int argc, char *argv[])
{
    unsigned addr = (argc > 1) ? (unsigned)strtol(argv[1], NULL, 0) : 0x27;
    int h, v, r;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    h = i2cOpen(I2C_BUS, addr, 0);           /* 핸들: 이후 통신에 쓰는 번호 */
    if (h < 0) {
        fprintf(stderr, "i2cOpen(bus %d, 0x%02X) 실패: %d\n", I2C_BUS, addr, h);
        gpioTerminate();
        return 1;
    }

    printf("I2C bus %d, 주소 0x%02X 에 0x00, 0x01, 0x02를 2초마다 보낸다.\n",
           I2C_BUS, addr);
    printf("기대 주소 바이트(쓰기) = 0x%02X (7비트 주소 << 1 | R/W=0)\n", addr << 1);

    while (running) {
        for (v = 0; v < 3 && running; v++) {
            r = i2cWriteByte((unsigned)h, (unsigned)v);   /* START, 주소+W, 데이터, STOP */
            printf("  write 0x%02X -> %s\n", v, r == 0 ? "ACK" : "실패(NACK?)");
        }
        gpioDelay(2000000);
    }

    i2cClose((unsigned)h);
    gpioTerminate();
    printf("\n정상 종료\n");
    return 0;
}
