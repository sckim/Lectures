/*
 * util.h : 실습 6-5  공용 도우미 함수
 */
#ifndef UTIL_H
#define UTIL_H

double util_mean(const int *data, int n);           /* 평균 */
double util_stddev(const int *data, int n);         /* 표준편차 (sqrt 사용 → -lm) */
void   util_print_bar(const char *label, double value, double base, double step);

#endif /* UTIL_H */
