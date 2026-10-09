/*
 * toggle_max.c : 실습 10-1  GPIO17을 최대 속도로 토글하고 계측기로 주파수를 잰다
 *
 * 회로 : GPIO17 (물리 핀 11) -> AD2 DIO 0 (Logic)  또는 Scope CH1(1+)
 *        GND (물리 핀 9)      -> AD2 GND(검은 선)   (공통 그라운드 필수)
 * 빌드 : gcc -Wall -O2 -pthread -o toggle_max toggle_max.c -lpigpio -lrt
 * 실행 : sudo ./toggle_max w     gpioWrite(17,1)/gpioWrite(17,0) 반복
 *        sudo ./toggle_max b     gpioWrite_Bits_0_31_Set/Clear 반복(레지스터 직접 쓰기)
 *        Ctrl+C로 멈추면 프로그램이 "스스로 센" 토글 주파수를 출력한다.
 *        이 값과 계측기로 잰 주파수를 비교한다.
 *
 * 주의 : 루프 안에 printf가 없다. 화면 출력은 토글보다 수천 배 느려서
 *        넣는 순간 "printf 속도"를 재게 된다. CPU 코어 하나를 100% 쓴다.
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <signal.h>
#include <pigpio.h>

#define PIN  17                              /* 물리 핀 11 */

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;
}

static double now_s(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec / 1.0e9;
}

int main(int argc, char *argv[])
{
    const uint32_t mask = 1u << PIN;
    int use_bits = (argc > 1 && strcmp(argv[1], "b") == 0);
    unsigned long long cycles = 0;
    double t0, dt;

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패: sudo, pigpiod 중지 여부를 확인하라.\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);
    gpioSetMode(PIN, PI_OUTPUT);

    printf("GPIO%d 토글 시작 [%s]. 계측기로 주파수를 재고 Ctrl+C로 끝낸다.\n",
           PIN, use_bits ? "Bits_Set/Clear" : "gpioWrite");
    fflush(stdout);

    t0 = now_s();
    if (use_bits) {
        while (running) {
            gpioWrite_Bits_0_31_Set(mask);    /* GPSET0 레지스터에 바로 쓰기 */
            gpioWrite_Bits_0_31_Clear(mask);  /* GPCLR0 레지스터에 바로 쓰기 */
            cycles++;
        }
    } else {
        while (running) {
            gpioWrite(PIN, 1);
            gpioWrite(PIN, 0);
            cycles++;
        }
    }
    dt = now_s() - t0;

    gpioWrite(PIN, 0);
    gpioSetMode(PIN, PI_INPUT);
    gpioTerminate();

    printf("\n%.2f 초 동안 %llu 주기 -> 평균 토글 주파수 %.3f MHz\n",
           dt, cycles, cycles / dt / 1.0e6);
    return 0;
}
