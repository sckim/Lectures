/*
 * led_blink_gpiod.c : 부록 B  libgpiod(v1 API) C 라이브러리로 LED 점멸
 *
 * 회로 : GPIO17 (물리 핀 11) -> 330 Ω -> LED -> GND   (실습 8-2와 같다)
 * 준비 : sudo apt install libgpiod-dev      (Bookworm 저장소: libgpiod 1.6.x)
 * 빌드 : gcc -Wall -o led_blink_gpiod led_blink_gpiod.c -lgpiod
 * 실행 : ./led_blink_gpiod                  (gpio 그룹 사용자는 sudo 불필요)
 *
 * pigpio 판(8장 led_blink.c)과 비교
 *   gpioInitialise()        -> gpiod_chip_open_by_name("gpiochip0")   칩을 연다
 *   gpioSetMode(17, OUTPUT) -> gpiod_chip_get_line() + gpiod_line_request_output()
 *                              "이 줄(line)은 내가 쓴다"고 커널에 요청한다. 다른 프로그램이
 *                              이미 요청한 줄이면 EBUSY로 실패한다(커널이 소유권 관리).
 *   gpioWrite(17, v)        -> gpiod_line_set_value(line, v)
 *   gpioTerminate()         -> gpiod_line_release() + gpiod_chip_close()
 *   pigpio와 달리 /dev/mem을 쓰지 않으므로 root가 필요 없고, Pi 5에서도 동작한다.
 *   (Pi 5의 40핀 헤더는 커널 6.6.47 이후 gpiochip0, 그 전에는 gpiochip4 - gpiodetect로 확인)
 *
 * 주의 : libgpiod 2.x는 API가 완전히 바뀌었다(gpiod_line_request, gpiod_line_settings 등).
 *        이 파일은 Bookworm 기본 패키지인 1.6.x 기준이다.
 */
#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <gpiod.h>

#define CHIP_NAME  "gpiochip0"
#define LED_LINE   17                    /* 칩 안의 오프셋 = BCM 번호 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

int main(void)
{
    struct gpiod_chip *chip;
    struct gpiod_line *line;

    signal(SIGINT, on_signal);           /* libgpiod는 시그널을 대신 받아 주지 않는다 */

    chip = gpiod_chip_open_by_name(CHIP_NAME);
    if (!chip) {
        perror("gpiod_chip_open_by_name");
        return 1;
    }
    line = gpiod_chip_get_line(chip, LED_LINE);
    if (!line || gpiod_line_request_output(line, "led_blink_gpiod", 0) < 0) {
        perror("gpiod_line_request_output");   /* 다른 프로그램이 쓰고 있으면 EBUSY */
        gpiod_chip_close(chip);
        return 1;
    }

    printf("%s line %d LED 점멸 (Ctrl+C로 종료)\n", CHIP_NAME, LED_LINE);
    while (running) {
        gpiod_line_set_value(line, 1);
        usleep(500000);
        gpiod_line_set_value(line, 0);
        usleep(500000);
    }

    gpiod_line_set_value(line, 0);
    gpiod_line_release(line);            /* 줄을 놓으면 커널이 다른 사용자에게 줄 수 있다 */
    gpiod_chip_close(chip);
    printf("\n정상 종료\n");
    return 0;
}
