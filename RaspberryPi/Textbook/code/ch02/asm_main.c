/* asm_main.c - asm_demo.c의 함수를 실제로 호출해 결과를 확인한다 */
#include <stdio.h>

int add(int a, int b);
int max_of(int a, int b);
int sum_to(int n);
int add_ten_plus_one(int x);

int main(void)
{
    printf("add(3, 4)           = %d\n", add(3, 4));
    printf("max_of(7, 2)        = %d\n", max_of(7, 2));
    printf("max_of(-1, 5)       = %d\n", max_of(-1, 5));
    printf("sum_to(10)          = %d\n", sum_to(10));
    printf("add_ten_plus_one(5) = %d\n", add_ten_plus_one(5));
    return 0;
}
