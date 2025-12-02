
#include <stdio.h>

int main(void)
{
    unsigned char flag = 0; // 0000 0000
    flag |= 1;              // 0000 0001
    flag |= 2;              // 0000 0010
    flag |= 4;              // 0000 0100
    printf("%u\n", flag);   // 7: 0000 0111
    if (flag & 1)           // & 연산자로 0000 0001 확인
        printf("The first LSB ON 0000 0001\n");
    else
        printf("The first LSB OFF\n");
    if (flag & 2) // & 연산자로 0000 0010 확인
        printf("The 2nd LSB ON 0000 0010\n");
    else
        printf("The 2nd LSB OFF\n");
    if (flag & 4) // & 연산자로 0000 0100 확인
        printf("The 3rd LSB ON 0000 0100\n");
    else
        printf("The 3rd LSB OFF\n");
    return 0;
}
