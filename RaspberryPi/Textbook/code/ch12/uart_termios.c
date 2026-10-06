/*
 * uart_termios.c : 12.5절 비교용  pigpio 없이 POSIX termios로 UART 루프백
 *
 * pigpio의 serOpen()이 내부에서 하는 일(장치 열기, raw 모드, 보율 설정)을
 * 리눅스 표준 API로 직접 해 본다. sudo가 필요 없다(dialout 그룹이면 충분).
 *
 * 회로 : 실습 12-1과 같다. GPIO14/TXD (물리 핀 8) <-> GPIO15/RXD (물리 핀 10) 점퍼
 * 빌드 : gcc -Wall -O2 -o uart_termios uart_termios.c
 * 실행 : ./uart_termios
 */
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>

int main(void)
{
    const char *dev = "/dev/serial0";
    const char *msg = "Hello, termios!\n";
    struct termios tio;
    char rx[64];
    int fd, n, got = 0;

    fd = open(dev, O_RDWR | O_NOCTTY);           /* 이 단말을 제어 터미널로 삼지 않는다 */
    if (fd < 0) {
        perror(dev);                             /* Permission denied -> dialout 그룹 */
        return 1;
    }

    tcgetattr(fd, &tio);
    cfmakeraw(&tio);                             /* 줄 편집·에코·특수 문자 처리 끄기 */
    cfsetispeed(&tio, B115200);
    cfsetospeed(&tio, B115200);
    tio.c_cflag |= CLOCAL | CREAD;               /* 모뎀 제어선 무시, 수신 허용 */
    tio.c_cflag &= ~(PARENB | CSTOPB | CRTSCTS); /* 패리티 없음, 정지 비트 1, 흐름 제어 없음 */
    tio.c_cc[VMIN]  = 0;                         /* read()는 */
    tio.c_cc[VTIME] = 5;                         /* 최대 0.5 s 기다린다 */
    tcsetattr(fd, TCSANOW, &tio);
    tcflush(fd, TCIOFLUSH);                      /* 남은 데이터 버리기 */

    if (write(fd, msg, strlen(msg)) < 0) {
        perror("write");
        close(fd);
        return 1;
    }
    while (got < (int)strlen(msg)) {
        n = read(fd, rx + got, sizeof(rx) - 1 - got);
        if (n <= 0)
            break;                               /* 0.5 s 동안 아무것도 안 오면 끝 */
        got += n;
    }
    rx[got] = '\0';

    printf("보냄 %zu B, 받음 %d B: %s", strlen(msg), got, got ? rx : "(없음)\n");
    close(fd);
    return 0;
}
