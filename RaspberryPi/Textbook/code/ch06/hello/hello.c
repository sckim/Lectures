/*
 * hello.c : 실습 6-1  gcc 빌드 4단계(전처리 → 컴파일 → 어셈블 → 링크) 관찰
 *
 * 한 번에 빌드 : gcc -Wall -o hello hello.c
 * 단계별 빌드  : make stages   (hello.i → hello.s → hello.o → hello)
 *
 * 원본 : Codes/hello.c (Raspberry Pi Codes §2.1).
 *        void main(void)를 표준 형태인 int main(void)로 고치고,
 *        전처리 결과를 보기 위해 매크로 GREETING을 추가하였다.
 */
#include <stdio.h>

#define GREETING "Hello, world!"    /* 전처리 단계에서 문자열로 치환된다 */

int main(void)
{
    printf("%s\n", GREETING);
    return 0;                       /* 0 = 정상 종료. 셸에서 echo $? 로 확인 */
}
