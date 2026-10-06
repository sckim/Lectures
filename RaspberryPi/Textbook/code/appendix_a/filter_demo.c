/*
 * filter_demo.c : 실습 A-6  FIR·IIR 저역통과 필터를 C로 구현하고 MATLAB 설계와 비교
 *
 * 빌드 : gcc -Wall -O2 -o filter_demo filter_demo.c -lm      (또는 make)
 * 실행 : ./filter_demo                  계수와 주파수 성분 크기 요약
 *        ./filter_demo csv > filter_out.csv   MATLAB에서 그래프로 비교할 데이터
 *
 * 신호 : fs = 100 Hz, 2초(200샘플). 5 Hz + 20 Hz + 30 Hz 사인(진폭 1) + 작은 잡음
 * 필터 : 차단 주파수 10 Hz 저역통과
 *        FIR = MATLAB fir1(20, 10/50)과 같은 방법(해밍 창, DC 이득 1)
 *        IIR = MATLAB butter(2, 10/50)과 같은 방법(사전 왜곡 쌍선형 변환)
 *
 * 원본 : 「Matlab 백서」 Filter Design의 FIR/IIR C 코드를 고쳤다.
 *        - math.h 누락(sin, M_PI) → 포함하고 -lm 링크, M_PI가 없을 때를 대비
 *        - rand()를 쓰면서 시드가 없어 결과 비교가 어려움 → 고정 시드 난수 사용
 *        - IIR 함수가 b와 a의 길이를 같다고 가정 → 길이를 따로 받는다
 *        - 계수를 손으로 옮겨 적음 → 같은 설계식으로 프로그램이 직접 계산한다
 */
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define FS     100.0           /* 샘플링 주파수 [Hz] */
#define FC     10.0            /* 차단 주파수 [Hz] */
#define FIR_N  20              /* FIR 차수. 탭(계수) 수는 차수 + 1 */
#define NTAP   (FIR_N + 1)
#define LEN    200             /* 신호 길이: 2초 */

/* ---------- 재현 가능한 잡음: 고정 시드 선형 합동 난수 ---------- */
static unsigned int seed = 2026u;

static double noise(void)                 /* -0.5 ~ +0.5 균등 분포 */
{
    seed = seed * 1103515245u + 12345u;
    return ((seed >> 16) & 0x7FFF) / 32768.0 - 0.5;
}

/* ---------- 설계 ① FIR: 창 함수법 (MATLAB fir1과 같은 순서) ---------- */
static void design_fir(double h[NTAP])
{
    double wn = FC / (FS / 2.0);          /* 나이퀴스트 주파수로 정규화 (0~1) */
    double sum = 0.0;

    for (int n = 0; n < NTAP; n++) {
        double m = n - FIR_N / 2.0;       /* 가운데를 0으로: 좌우 대칭 */
        double ideal = (m == 0.0) ? wn : sin(M_PI * wn * m) / (M_PI * m);
        double hamming = 0.54 - 0.46 * cos(2.0 * M_PI * n / FIR_N);
        h[n] = ideal * hamming;
        sum += h[n];
    }
    for (int n = 0; n < NTAP; n++)        /* 직류(0 Hz) 이득을 정확히 1로 */
        h[n] /= sum;
}

/* ---------- 설계 ② IIR: 2차 버터워스 (MATLAB butter(2, Wn)과 같은 결과) ---------- */
static void design_butter2(double b[3], double a[3])
{
    double k = tan(M_PI * FC / FS);       /* 주파수 사전 왜곡(prewarping) */
    double r2 = sqrt(2.0);                /* 2차 버터워스의 감쇠 계수 2ζ = √2 */
    double norm = 1.0 / (1.0 + r2 * k + k * k);

    b[0] = k * k * norm;
    b[1] = 2.0 * b[0];
    b[2] = b[0];
    a[0] = 1.0;
    a[1] = 2.0 * (k * k - 1.0) * norm;
    a[2] = (1.0 - r2 * k + k * k) * norm;
}

/* ---------- 필터링: MATLAB y = filter(b, a, x) 와 같은 차분 방정식 ----------
 *   a[0]·y[n] = Σ b[k]·x[n-k]  −  Σ(k≥1) a[k]·y[n-k]
 *   FIR은 a = {1} 인 특별한 경우이다(nb = 탭 수, na = 1).                    */
static void filter_ba(const double *b, int nb, const double *a, int na,
                      const double *x, double *y, int len)
{
    for (int n = 0; n < len; n++) {
        double acc = 0.0;
        for (int k = 0; k < nb && k <= n; k++)
            acc += b[k] * x[n - k];
        for (int k = 1; k < na && k <= n; k++)
            acc -= a[k] * y[n - k];
        y[n] = acc / a[0];
    }
}

/* ---------- 한 주파수 성분의 크기와 위상 (DFT 한 칸) ----------
 *   from부터 count개 샘플을 쓴다. count 안에 정수 개 주기가 들어가면 정확하다. */
static void tone(const double *s, int from, int count, double f,
                 double *amp, double *phase)
{
    double re = 0.0, im = 0.0;
    for (int n = from; n < from + count; n++) {
        double w = 2.0 * M_PI * f * n / FS;
        re += s[n] * cos(w);
        im -= s[n] * sin(w);
    }
    *amp = 2.0 * sqrt(re * re + im * im) / count;
    *phase = atan2(im, re);
}

static void print_coef(const char *name, const double *c, int n)
{
    printf("%s = [", name);
    for (int i = 0; i < n; i++) {
        double v = (fabs(c[i]) < 5e-7) ? 0.0 : c[i];   /* -0.000000 표시 방지 */
        printf("%s%.6f", i ? " " : "", v);
    }
    printf("]\n");
}

int main(int argc, char *argv[])
{
    static double x[LEN], y_fir[LEN], y_iir[LEN];
    double h[NTAP], b[3], a[3];
    const double one = 1.0;
    const double freqs[3] = { 5.0, 20.0, 30.0 };

    /* 1) 시험 신호 만들기 */
    for (int n = 0; n < LEN; n++) {
        double t = n / FS;
        x[n] = sin(2 * M_PI * 5 * t) + sin(2 * M_PI * 20 * t)
             + sin(2 * M_PI * 30 * t) + 0.2 * noise();
    }

    /* 2) 필터 설계와 적용 */
    design_fir(h);
    design_butter2(b, a);
    filter_ba(h, NTAP, &one, 1, x, y_fir, LEN);
    filter_ba(b, 3, a, 3, x, y_iir, LEN);

    /* 3-a) CSV 모드: MATLAB에서 readmatrix로 읽어 그래프를 그린다 */
    if (argc > 1 && strcmp(argv[1], "csv") == 0) {
        printf("n,t,x,y_fir,y_iir\n");
        for (int n = 0; n < LEN; n++)
            printf("%d,%.2f,%.6f,%.6f,%.6f\n", n, n / FS, x[n], y_fir[n], y_iir[n]);
        return 0;
    }

    /* 3-b) 요약 모드 */
    printf("fs = %.0f Hz, fc = %.0f Hz, FIR %d차(%d탭), IIR 2차 버터워스\n\n",
           FS, FC, FIR_N, NTAP);
    print_coef("b_fir", h, NTAP);
    print_coef("b_iir", b, 3);
    print_coef("a_iir", a, 3);

    /* 처음 100샘플은 필터가 자리 잡는 구간(과도 응답)이므로 뒤 1초만 분석한다 */
    printf("\n성분      입력   FIR출력  IIR출력   FIR지연   IIR지연  (지연 단위: 샘플)\n");
    for (int i = 0; i < 3; i++) {
        double a_in, p_in, a_fir, p_fir, a_iir, p_iir;
        tone(x, 100, 100, freqs[i], &a_in, &p_in);
        tone(y_fir, 100, 100, freqs[i], &a_fir, &p_fir);
        tone(y_iir, 100, 100, freqs[i], &a_iir, &p_iir);
        /* 위상 차이를 샘플 수로 바꾼 것 = 그 주파수가 늦게 나오는 정도 */
        double per = FS / freqs[i];                      /* 한 주기의 샘플 수 */
        double d_fir = fmod(p_in - p_fir + 4 * M_PI, 2 * M_PI) / (2 * M_PI) * per;
        double d_iir = fmod(p_in - p_iir + 4 * M_PI, 2 * M_PI) / (2 * M_PI) * per;
        printf("%4.0f Hz  %6.3f  %7.3f  %7.3f", freqs[i], a_in, a_fir, a_iir);
        /* 출력이 거의 0이면 위상은 잡음에 묻혀 의미가 없으므로 '-'로 표시한다 */
        if (a_fir > 0.05) printf("   %7.2f", d_fir); else printf("   %7s", "-");
        if (a_iir > 0.05) printf("   %7.2f", d_iir); else printf("   %7s", "-");
        printf("\n");
    }
    return 0;
}
