/*
 * calculate_pi2.c : 실습 6-2  스피곳(spigot) 알고리즘으로 원주율 800자리 계산
 *
 * 부동소수점 없이 정수 나눗셈과 나머지만으로 원주율을 4자리씩 차례로 뽑아낸다.
 * (수도꼭지(spigot)에서 물이 한 방울씩 떨어지듯 자릿수가 나온다는 뜻)
 *
 * 빌드 : gcc -Wall -o calculate_pi2 calculate_pi2.c
 * 실행 : ./calculate_pi2
 *
 * 원본 : Codes/calculate_pi2.c (Raspberry Pi Codes §2.3).
 *        알고리즘은 그대로 두고, 40자리마다 줄을 바꾸어 출력하도록 하였다.
 *        MAX_ARRAY 2800 / 14 = 200회 × 4자리 = 800자리를 출력한다.
 */
#include <stdio.h>

#define SCALE      10000    /* 한 번에 4자리(10^4)씩 뽑는다 */
#define MAX_ARRAY  2800
#define ARRAY_INIT 2000     /* SCALE / 5 */

int main(void)
{
    int i, j, sum, carry = 0, printed = 0;
    int array[MAX_ARRAY + 1];

    for (i = 0; i <= MAX_ARRAY; ++i)
        array[i] = ARRAY_INIT;

    for (i = MAX_ARRAY; i; i -= 14) {
        sum = 0;
        for (j = i; j > 0; --j) {
            sum = sum * j + SCALE * array[j];
            array[j] = sum % (j * 2 - 1);
            sum /= (j * 2 - 1);
        }
        printf("%04d", carry + sum / SCALE);
        carry = sum % SCALE;
        printed += 4;
        if (printed % 40 == 0)      /* 40자리마다 줄바꿈 */
            printf("\n");
    }
    if (printed % 40 != 0)
        printf("\n");
    return 0;
}
