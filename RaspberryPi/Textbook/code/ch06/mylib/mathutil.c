/*
 * mathutil.c : 실습 6-3  libmylib에 들어갈 함수들의 "정의"
 *
 * 정적 라이브러리 : gcc -Wall -c mathutil.c -o mathutil.o
 *                   ar rcs libmylib.a mathutil.o
 * 공유 라이브러리 : gcc -Wall -fPIC -c mathutil.c -o mathutil.pic.o
 *                   gcc -shared -o libmylib.so mathutil.pic.o
 */
#include "mathutil.h"

int mu_clamp(int value, int lo, int hi)
{
    if (value < lo)
        return lo;
    if (value > hi)
        return hi;
    return value;
}

double mu_average(const int *data, int n)
{
    long sum = 0;

    if (n <= 0)
        return 0.0;
    for (int i = 0; i < n; i++)
        sum += data[i];
    return (double)sum / n;
}

double mu_c_to_f(double celsius)
{
    return celsius * 9.0 / 5.0 + 32.0;
}

const char *mu_version(void)
{
    return "mylib 1.0";
}
