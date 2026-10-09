/*
 * serialTest_pigpio.c : 부록 B  UART 루프백 시험 - 0~255를 보내고 되돌아오는 값을 출력
 *
 * 회로 : TXD GPIO14 (물리 핀 8)  <-- 점퍼선 -->  RXD GPIO15 (물리 핀 10)   (루프백)
 * 준비 : sudo raspi-config -> Interface Options -> Serial Port
 *          "login shell over serial?" No,  "serial port hardware enabled?" Yes
 *        또는 /boot/firmware/config.txt 에 enable_uart=1 (필요하면 dtoverlay=disable-bt)
 *        /boot/firmware/cmdline.txt 에서 console=serial0,115200 을 지운 뒤 재부팅
 * 빌드 : gcc -Wall -pthread -o serialTest_pigpio serialTest_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./serialTest_pigpio
 *
 * 원본 : wiringpi/serialTest.c (Raspberry Pi Codes §4.5)
 *        serialOpen("/dev/ttyAMA0", 115200)  -> serOpen("/dev/serial0", 115200, 0)
 *        serialPutchar / serialDataAvail / serialGetchar
 *                                            -> serWriteByte / serDataAvailable / serReadByte
 *        millis()                            -> gpioTick() (us, 32비트, 약 72분마다 0으로 돌아감)
 *        /dev/serial0 은 "GPIO14/15에 연결된 UART"를 가리키는 별칭이라, Bluetooth 설정에
 *        따라 ttyAMA0 이든 ttyS0 이든 같은 이름으로 열 수 있다.
 *
 * 주의 : serialGetchar()는 데이터가 없으면 최대 10초 기다리지만, serReadByte()는
 *        기다리지 않고 바로 음수(PI_SER_READ_NO_DATA)를 돌려준다. 그래서
 *        serDataAvailable()로 먼저 확인한다.
 */
#include <stdio.h>
#include <stdint.h>
#include <signal.h>
#include <pigpio.h>

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(void)
{
    char dev[] = "/dev/serial0";         /* serOpen의 인자는 char * (const 아님) */
    int h, count, c;
    uint32_t nextTime;

    if (gpioInitialise() < 0) {          /* ser* 함수도 초기화 뒤에 쓴다 */
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);

    h = serOpen(dev, 115200, 0);
    if (h < 0) {
        fprintf(stderr, "%s 를 열 수 없다 (오류 %d). UART 설정을 확인하라.\n", dev, h);
        gpioTerminate();
        return 1;
    }

    nextTime = gpioTick() + 300000;      /* 300 ms 뒤 */

    for (count = 0; count < 256 && running; ) {
        /* 시각 비교는 뺄셈 결과를 부호 있는 수로 본다 -> 72분 랩어라운드에도 안전 */
        if ((int32_t)(gpioTick() - nextTime) >= 0) {
            printf("\nOut: %3d: ", count);
            fflush(stdout);
            serWriteByte(h, (unsigned)count);
            nextTime += 300000;
            ++count;
        }

        gpioDelay(3000);                 /* delay(3) */

        while (serDataAvailable(h) > 0) {
            c = serReadByte(h);
            if (c < 0)
                break;
            printf(" -> %3d", c);
            fflush(stdout);
        }
    }

    printf("\n");
    serClose(h);
    gpioTerminate();
    return 0;
}
