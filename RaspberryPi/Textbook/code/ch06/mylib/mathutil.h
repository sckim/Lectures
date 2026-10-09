/*
 * mathutil.h : 실습 6-3  나만의 라이브러리 libmylib의 헤더 (함수 "선언"만 있다)
 *
 * 이 헤더를 #include 하는 쪽은 함수의 이름·인자·반환형(원형, prototype)만 알게 된다.
 * 함수의 "정의"(실제 코드)는 mathutil.c → libmylib.a / libmylib.so 안에 있다.
 */
#ifndef MATHUTIL_H          /* include guard: 같은 헤더가 두 번 들어와도 한 번만 처리 */
#define MATHUTIL_H

int    mu_clamp(int value, int lo, int hi);        /* value를 [lo, hi] 범위로 자른다 */
double mu_average(const int *data, int n);         /* 정수 배열의 평균 */
double mu_c_to_f(double celsius);                  /* 섭씨 → 화씨 */
const char *mu_version(void);                      /* 라이브러리 버전 문자열 */

#endif /* MATHUTIL_H */
