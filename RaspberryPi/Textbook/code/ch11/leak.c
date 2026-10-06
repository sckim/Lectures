/*
 * leak.c : 11.3.4절 보강  빌린 메모리를 돌려주지 않는 실수(메모리 누수)를 일부러 만든 예
 *
 * 회로 : 없음 (PC(WSL)에서도 실행된다)
 * 빌드 : make membug                                   (= gcc -Wall -g -O0 -o leak leak.c)
 *        make asan                                     (AddressSanitizer 판: leak_asan)
 * 실행 : valgrind --leak-check=full ./leak              Valgrind로 검사
 *        ./leak_asan                                   끝날 때 LeakSanitizer가 누수를 보고한다
 */
#include <stdlib.h>
#include <string.h>

int main(void)
{
    char *p = malloc(100);  /* 100바이트를 빌린다 */
    memset(p, 0, 100);
    return 0;               /* 실수: free(p)를 빠뜨렸다 */
}
