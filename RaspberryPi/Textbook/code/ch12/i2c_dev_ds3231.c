/*
 * i2c_dev_ds3231.c : 12.6절 비교용  pigpio 없이 /dev/i2c-1 로 DS3231 시각 읽기
 *
 * 커널의 i2c-dev 인터페이스(open -> ioctl(I2C_SLAVE) -> write/read)를 직접 쓴다.
 * pigpio의 i2cOpen()/i2cReadI2CBlockData()도 내부에서 같은 장치 파일을 연다.
 * sudo가 필요 없다(i2c 그룹이면 충분).
 *
 * 회로 : 실습 12-4와 같다 (DS3231, 주소 0x68)
 * 빌드 : gcc -Wall -O2 -o i2c_dev_ds3231 i2c_dev_ds3231.c
 * 실행 : ./i2c_dev_ds3231
 */
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>

#define DS3231_ADDR 0x68

static int bcd2dec(int bcd) { return (bcd >> 4) * 10 + (bcd & 0x0F); }

int main(void)
{
    unsigned char reg = 0x00;          /* 읽기를 시작할 레지스터 주소 */
    unsigned char b[7];
    int fd;

    fd = open("/dev/i2c-1", O_RDWR);
    if (fd < 0) {
        perror("/dev/i2c-1");          /* No such file -> I2C 꺼짐, Permission -> i2c 그룹 */
        return 1;
    }
    if (ioctl(fd, I2C_SLAVE, DS3231_ADDR) < 0) {   /* 이후 read/write의 상대 주소 */
        perror("ioctl(I2C_SLAVE)");    /* Device or resource busy -> 커널 드라이버가 사용 중 */
        close(fd);
        return 1;
    }

    /* 1) 쓰기: START, 0x68+W, 0x00, STOP  -> 레지스터 포인터를 0으로 */
    if (write(fd, &reg, 1) != 1) {
        perror("write");               /* Remote I/O error -> NACK (장치 없음) */
        close(fd);
        return 1;
    }
    /* 2) 읽기: START, 0x68+R, 7바이트, STOP  -> 0x00~0x06 */
    if (read(fd, b, 7) != 7) {
        perror("read");
        close(fd);
        return 1;
    }

    printf("20%02d-%02d-%02d %02d:%02d:%02d\n",
           bcd2dec(b[6]), bcd2dec(b[5] & 0x1F), bcd2dec(b[4] & 0x3F),
           bcd2dec(b[2] & 0x3F), bcd2dec(b[1] & 0x7F), bcd2dec(b[0] & 0x7F));
    close(fd);
    return 0;
}
