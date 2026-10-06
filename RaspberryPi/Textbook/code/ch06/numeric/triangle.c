/*
 * triangle.c : 실습 6-2  삼각함수 계산 (수학 라이브러리 libm 링크 연습)
 *
 * 빌드 : gcc -Wall -O0 -o triangle triangle.c -lm
 *        -lm을 빼면 링크 단계에서 undefined reference to `sin' 오류가 난다.
 *
 * 원본 : Codes/triangle.c (Raspberry Pi Codes §2.4).
 *        math.h가 이미 M_PI를 정의하는 환경에서도 경고가 나지 않도록
 *        #ifndef로 감쌌다(-std=c11처럼 M_PI를 정의하지 않는 모드 대비).
 */
#include <stdio.h>
#include <math.h>       /* sin, cos, tan 의 "선언" (정의는 libm에 있다) */

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

static double getRadian(double degree)
{
    return degree * (M_PI / 180.0);
}

int main(void)
{
    double num = getRadian(60);

    printf("sin60 : %5.4f\n", sin(num));
    printf("cos60 : %5.4f\n", cos(num));
    printf("tan60 : %5.4f\n", tan(num));
    return 0;
}
