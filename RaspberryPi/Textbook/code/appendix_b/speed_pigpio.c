/*
 * speed_pigpio.c : 부록 B  pigpio로 GPIO 쓰기 속도 측정 (gpioWrite vs 레지스터 일괄 쓰기)
 *
 * 회로 : GPIO17 (물리 핀 11). LED를 달아도 되고, 오실로스코프·로직 분석기 프로브를
 *        물려 실제 토글 주파수를 함께 재면 더 좋다(10장).
 * 빌드 : gcc -Wall -O2 -pthread -o speed_pigpio speed_pigpio.c -lpigpio -lrt
 * 실행 : sudo ./speed_pigpio
 *
 * 원본 : wiringpi/speed.c (Raspberry Pi Codes §4.2.3)
 *        원본은 같은 핀을 WiringPi 번호/BCM 번호/물리 번호/sysfs/문자 디바이스로
 *        바꿔 가며 digitalWrite(pin, 1)을 반복했다. pigpio는 BCM 번호만 쓰고
 *        sysfs·문자 디바이스 경로가 없으므로, 대신 다음 네 가지를 비교한다.
 *          A. gpioWrite(17, 1) 반복                 - 원본과 같은 "같은 값 쓰기"
 *          B. gpioWrite_Bits_0_31_Set(1<<17) 반복   - GPSET0 레지스터에 바로 쓰기
 *          C. gpioWrite 1/0 번갈아 (토글)           - 핀에 실제 파형이 나온다
 *          D. Set/Clear 번갈아 (토글)
 *        millis() 대신 clock_gettime(CLOCK_MONOTONIC)으로 경과 시간을 잰다.
 *
 * 주의 : 결과는 CPU 클럭(전원 관리), 다른 프로세스, -O 옵션에 따라 달라진다.
 *        여러 번 재고, 토글 주파수는 계측기로 확인한 값을 기록한다.
 */
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <signal.h>
#include <pigpio.h>

#define PIN         17                   /* 물리 핀 11 */
#define COUNT       10000000
#define PASSES      5

static volatile sig_atomic_t running = 1;

static void on_signal(int signum)
{
    (void)signum;
    running = 0;      /* 측정 루프 안은 건드리지 않고, 패스 사이에서만 확인한다 */
}

static double now_ms(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec / 1.0e6;
}

static void report(const char *name, double sum_ms, int ops_per_loop)
{
    double avg = sum_ms / PASSES;
    double ops = (double)COUNT * ops_per_loop / (avg / 1000.0);
    printf(". Av: %8.1f ms : %12.0f writes/sec", avg, ops);
    if (ops_per_loop == 2)               /* 토글 1주기 = 쓰기 2번 */
        printf("  (토글 이론 주파수 %.2f MHz)", ops / 2.0 / 1.0e6);
    printf("   [%s]\n", name);
}

int main(void)
{
    const uint32_t mask = 1u << PIN;
    double t0, dt, sum;
    int i, n;

    printf("Raspberry Pi pigpio GPIO speed test program (v%u)\n", gpioVersion());
    printf("===============================================\n");

    if (gpioInitialise() < 0) {
        fprintf(stderr, "pigpio 초기화 실패\n");
        return 1;
    }
    gpioSetSignalFunc(SIGINT, on_signal);
    gpioSetMode(PIN, PI_OUTPUT);

    printf("\nA. gpioWrite(%d, 1) x %d\n  ", PIN, COUNT);
    for (sum = 0, i = 0; i < PASSES && running; i++) {
        t0 = now_ms();
        for (n = 0; n < COUNT; n++)
            gpioWrite(PIN, 1);
        dt = now_ms() - t0;
        sum += dt;
        printf(" %7.1f", dt);
        fflush(stdout);
    }
    if (!running) goto done;
    report("gpioWrite", sum, 1);

    printf("\nB. gpioWrite_Bits_0_31_Set(1<<%d) x %d\n  ", PIN, COUNT);
    for (sum = 0, i = 0; i < PASSES && running; i++) {
        t0 = now_ms();
        for (n = 0; n < COUNT; n++)
            gpioWrite_Bits_0_31_Set(mask);
        dt = now_ms() - t0;
        sum += dt;
        printf(" %7.1f", dt);
        fflush(stdout);
    }
    if (!running) goto done;
    report("Bits_Set", sum, 1);

    printf("\nC. gpioWrite 1/0 toggle x %d\n  ", COUNT);
    for (sum = 0, i = 0; i < PASSES && running; i++) {
        t0 = now_ms();
        for (n = 0; n < COUNT; n++) {
            gpioWrite(PIN, 1);
            gpioWrite(PIN, 0);
        }
        dt = now_ms() - t0;
        sum += dt;
        printf(" %7.1f", dt);
        fflush(stdout);
    }
    if (!running) goto done;
    report("gpioWrite toggle", sum, 2);

    printf("\nD. Bits_Set/Bits_Clear toggle x %d\n  ", COUNT);
    for (sum = 0, i = 0; i < PASSES && running; i++) {
        t0 = now_ms();
        for (n = 0; n < COUNT; n++) {
            gpioWrite_Bits_0_31_Set(mask);
            gpioWrite_Bits_0_31_Clear(mask);
        }
        dt = now_ms() - t0;
        sum += dt;
        printf(" %7.1f", dt);
        fflush(stdout);
    }
    if (!running) goto done;
    report("Bits toggle", sum, 2);

done:
    gpioWrite(PIN, 0);
    gpioSetMode(PIN, PI_INPUT);
    gpioTerminate();
    return 0;
}
