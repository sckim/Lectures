/*
 * main.c : 실습 6-3  libmylib을 사용하는 프로그램
 *
 * 정적 링크 : gcc -Wall -o main_static main.c -L. -l:libmylib.a
 * 공유 링크 : gcc -Wall -o main_shared main.c -L. -lmylib
 *             실행 전 라이브러리 위치를 알려 준다: LD_LIBRARY_PATH=. ./main_shared
 */
#include <stdio.h>
#include "mathutil.h"       /* 내가 만든 헤더는 " " 로 포함한다 */

int main(void)
{
    int temps[] = { 21, 23, 22, 25, 24 };
    int n = sizeof(temps) / sizeof(temps[0]);
    double avg = mu_average(temps, n);

    printf("%s\n", mu_version());
    printf("average = %.1f C = %.1f F\n", avg, mu_c_to_f(avg));
    printf("clamp(150, 0, 100) = %d\n", mu_clamp(150, 0, 100));
    return 0;
}
