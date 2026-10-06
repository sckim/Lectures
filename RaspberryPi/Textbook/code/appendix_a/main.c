/*
 * main.c : 실습 A-3  MATLAB Coder가 만든 moving_average()를 부르는 메인 프로그램
 *
 * 준비 : build_ma.m 으로 만든 codegen/lib/moving_average/ 폴더를 이 파일 옆에 둔다.
 * 빌드 : make ma
 *        (직접 하면) main.c와 codegen/lib/moving_average 폴더의 모든 .c 파일을
 *        -I codegen/lib/moving_average 옵션과 함께 gcc로 컴파일하고 -lm을 링크한다.
 * 실행 : ./bio_signal_processor
 *        nohup ./bio_signal_processor > signal_output.log 2>&1 &   (로그아웃해도 계속)
 *
 * 원본 : 「Matlab 백서」 2.3절 main.c를 고쳤다.
 *        - rand()를 쓰면서 stdlib.h가 없음 → 직접 만든 고정 시드 난수로 대체
 *        - 의미 없는 난수 대신 맥파(PPG)와 비슷한 1.2 Hz 신호 + 잡음을 만든다
 *        - 블록 경계에서 출력이 이어지는지(필터 상태 유지) 확인하는 출력 추가
 */
#include <stdio.h>
#include <math.h>
#include <unistd.h>                      /* usleep */
#include "moving_average.h"              /* MATLAB Coder가 만든 헤더 */
#include "moving_average_initialize.h"
#include "moving_average_terminate.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define BLOCK   100      /* moving_average.m 입력 크기(1x100)와 반드시 같아야 한다 */
#define FS      100.0    /* 샘플링 주파수 [Hz] → 블록 하나 = 1초 */
#define NBLOCK  5        /* 처리할 블록 수 */

static unsigned int seed = 12345u;

static double noise(void)                 /* -0.5 ~ +0.5, 실행할 때마다 같은 값 */
{
    seed = seed * 1103515245u + 12345u;
    return ((seed >> 16) & 0x7FFF) / 32768.0 - 0.5;
}

/* 센서를 읽는 자리. 실제로는 I2C/SPI ADC(12장)를 읽는다.
 * 여기서는 분당 72회 맥박(1.2 Hz) 비슷한 사인파에 잡음을 더한다. */
static void read_sensor(double *buf, int n, long start)
{
    for (int i = 0; i < n; i++) {
        double t = (start + i) / FS;
        buf[i] = sin(2.0 * M_PI * 1.2 * t) + 0.5 * noise();
    }
}

/* 거칠기: 이웃한 두 샘플 차이의 RMS. 잡음이 많을수록 크다 */
static double roughness(const double *s, int n)
{
    double acc = 0.0;
    for (int i = 1; i < n; i++)
        acc += (s[i] - s[i - 1]) * (s[i] - s[i - 1]);
    return sqrt(acc / (n - 1));
}

int main(void)
{
    double x[BLOCK], y[BLOCK];
    double last_y = 0.0;

    moving_average_initialize();          /* persistent 상태(필터 지연값) 초기화 */
    printf("이동 평균 필터 시작: %d블록 x %d샘플\n", NBLOCK, BLOCK);

    for (int k = 0; k < NBLOCK; k++) {
        read_sensor(x, BLOCK, (long)k * BLOCK);
        moving_average(x, y);             /* MATLAB에서 만든 알고리즘 호출 */

        printf("block %d: 거칠기 입력 %.3f -> 출력 %.3f, 경계 y[99]->y[0] 변화 %+.3f\n",
               k, roughness(x, BLOCK), roughness(y, BLOCK),
               (k == 0) ? 0.0 : y[0] - last_y);
        last_y = y[BLOCK - 1];

        usleep(100000);  /* 실제 센서라면 다음 블록(1초)을 기다리는 자리. 예제는 0.1초 */
    }

    moving_average_terminate();
    return 0;
}
