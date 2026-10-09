/*
 * counter_a.c : 6.4절  multiple definition 오류 관찰 (counter_b.c와 함께 빌드)
 *
 * 두 파일이 모두 전역 변수 counter를 "정의"한다.
 * 빌드 : gcc -Wall -o counter counter_a.c counter_b.c
 *        → multiple definition of `counter'
 * 고치기 : 정의는 한 파일(counter_a.c)에만 두고, 다른 파일은 extern으로 "선언"만 한다.
 *          gcc -Wall -DFIX -o counter counter_a.c counter_b.c
 */
#include <stdio.h>

int counter;                    /* 정의(definition): 메모리를 실제로 잡는다 */

void count_up(void);            /* counter_b.c에 있는 함수의 선언 */

int main(void)
{
    count_up();
    count_up();
    printf("counter = %d\n", counter);
    return 0;
}
