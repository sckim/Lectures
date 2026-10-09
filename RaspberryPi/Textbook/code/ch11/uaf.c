/*
 * uaf.c : 11.3.4절 보강  해제한 메모리를 다시 읽는 실수(use-after-free)를 일부러 만든 예
 *
 * 회로 : 없음 (PC(WSL)에서도 실행된다)
 * 빌드 : make membug                                   (= gcc -Wall -g -O0 -o uaf uaf.c)
 *        make asan                                     (AddressSanitizer 판: uaf_asan)
 * 실행 : valgrind --leak-check=full ./uaf               Valgrind로 검사
 *        ./uaf_asan                                    ASan이 오류를 찾으면 바로 멈춘다
 */
#include <stdlib.h>

int main(void)
{
    int *p = malloc(100);   /* 100바이트를 빌린다 */
    free(p);                /* 돌려준다 */
    return p[0];            /* 실수: 이미 돌려준 메모리를 읽는다 */
}
