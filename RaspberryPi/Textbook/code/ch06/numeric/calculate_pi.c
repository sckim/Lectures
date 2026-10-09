/*
 * calculate_pi.c : 실습 6-2  라이프니츠 급수로 원주율 계산
 *
 *   pi/4 = 1 - 1/3 + 1/5 - 1/7 + ...      (항을 많이 더할수록 pi에 가까워진다)
 *
 * 빌드 : gcc -Wall -O0 -o calculate_pi calculate_pi.c
 * 실행 : time ./calculate_pi       (-O0과 -O2로 빌드해 실행 시간을 비교해 본다)
 *
 * 원본 : Codes/calculate_pi.c (Raspberry Pi Codes §2.2).
 *        출력 끝에 줄바꿈이 없어 프롬프트가 같은 줄에 붙던 것을 고치고,
 *        반복 횟수를 정수 상수로 바꾸었다(원본은 double 변수 num으로 셌다).
 */
#include <stdio.h>

#define TERMS 10000000L     /* 더할 항의 개수: 1천만 개 */

int main(void)
{
    double sum = 0.0;
    double sign = 1.0;      /* +1, -1, +1, ... */
    double denom = 1.0;     /* 1, 3, 5, 7, ... */

    for (long n = 0; n < TERMS; n++) {
        sum += sign / denom;
        sign = -sign;
        denom += 2.0;
    }
    printf("terms = %ld, pi = %.10f\n", TERMS, 4.0 * sum);
    return 0;
}
