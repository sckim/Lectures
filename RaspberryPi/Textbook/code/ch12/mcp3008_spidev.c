/*
 * mcp3008_spidev.c : 12.7절 비교용  pigpio 없이 커널 spidev로 MCP3008 읽기
 *
 * 커널 SPI 드라이버(spi-bcm2835)가 만든 /dev/spidev0.0 에 ioctl로 전송을 맡긴다.
 * sudo가 필요 없다(spi 그룹이면 충분).
 *
 * 회로 : 실습 12-5와 같다 (MCP3008 CS = CE0)
 * 준비 : dtparam=spi=on (raspi-config > Interface Options > SPI), 재부팅
 *        pigpio로 SPI를 쓰는 프로그램(mcp3008_adc)과 동시에 실행하지 않는다.
 * 빌드 : gcc -Wall -O2 -o mcp3008_spidev mcp3008_spidev.c
 * 실행 : ./mcp3008_spidev       (CH0)
 *        ./mcp3008_spidev 3     (CH3)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

int main(int argc, char *argv[])
{
    int ch = (argc > 1) ? atoi(argv[1]) & 7 : 0;
    uint8_t mode = SPI_MODE_0, bits = 8;
    uint32_t speed = 1000000;
    uint8_t tx[3] = { 0x01, (uint8_t)(0x80 | (ch << 4)), 0x00 };
    uint8_t rx[3] = { 0, 0, 0 };
    struct spi_ioc_transfer tr;
    int fd, value;

    fd = open("/dev/spidev0.0", O_RDWR);         /* 버스 0, CS 0 */
    if (fd < 0) {
        perror("/dev/spidev0.0");                /* 없으면 dtparam=spi=on 확인 */
        return 1;
    }
    ioctl(fd, SPI_IOC_WR_MODE, &mode);
    ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
    ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);

    memset(&tr, 0, sizeof(tr));
    tr.tx_buf = (unsigned long)tx;               /* 보낼 버퍼와 받을 버퍼를 따로 준다 */
    tr.rx_buf = (unsigned long)rx;
    tr.len = 3;
    tr.speed_hz = speed;
    tr.bits_per_word = bits;

    if (ioctl(fd, SPI_IOC_MESSAGE(1), &tr) < 0) { /* CS Low -> 3바이트 교환 -> CS High */
        perror("SPI_IOC_MESSAGE");
        close(fd);
        return 1;
    }
    value = ((rx[1] & 0x03) << 8) | rx[2];
    printf("CH%d = %d (%.3f V)\n", ch, value, value * 3.3 / 1024.0);
    close(fd);
    return 0;
}
