/*
 * util.c : 실습 6-5  평균·표준편차·막대 출력
 */
#include <stdio.h>
#include <math.h>
#include "util.h"

double util_mean(const int *data, int n)
{
    double sum = 0.0;

    for (int i = 0; i < n; i++)
        sum += data[i];
    return n > 0 ? sum / n : 0.0;
}

double util_stddev(const int *data, int n)
{
    double m = util_mean(data, n), acc = 0.0;

    for (int i = 0; i < n; i++)
        acc += (data[i] - m) * (data[i] - m);
    return n > 0 ? sqrt(acc / n) : 0.0;
}

/* value가 base보다 step의 몇 배 큰지를 # 개수로 그린다 */
void util_print_bar(const char *label, double value, double base, double step)
{
    int len = (int)((value - base) / step + 0.5);

    printf("%-6s %8.2f |", label, value);
    for (int i = 0; i < len && i < 60; i++)
        putchar('#');
    putchar('\n');
}
