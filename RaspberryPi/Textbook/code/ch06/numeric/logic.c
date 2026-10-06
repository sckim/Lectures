/*
 * logic.c : 실습 6-2  비트 연산으로 플래그 다루기
 *
 * 한 바이트의 각 비트를 스위치처럼 쓴다. 하드웨어 레지스터(GPIO 설정 등)를
 * 다룰 때 똑같은 방법을 쓴다: 켜기 |=, 끄기 &= ~, 뒤집기 ^=, 확인 &.
 *
 * 빌드 : gcc -Wall -o logic logic.c
 *
 * 원본 : Codes/logic.c (Raspberry Pi Codes §2.5). 앞부분(비트 켜고 확인하기)은
 *        원본과 같고, 비트 끄기·뒤집기와 2진수 출력 함수를 추가하였다.
 */
#include <stdio.h>

#define BIT0 (1u << 0)      /* 0000 0001 */
#define BIT1 (1u << 1)      /* 0000 0010 */
#define BIT2 (1u << 2)      /* 0000 0100 */

/* 8비트 값을 "0000 0111" 꼴로 출력한다 */
static void print_bin(const char *label, unsigned char v)
{
    printf("%-14s %3u : ", label, v);
    for (int b = 7; b >= 0; b--) {
        putchar((v >> b) & 1 ? '1' : '0');
        if (b == 4)
            putchar(' ');
    }
    putchar('\n');
}

int main(void)
{
    unsigned char flag = 0;         /* 0000 0000 */

    flag |= BIT0;                   /* 0000 0001 */
    flag |= BIT1;                   /* 0000 0010 */
    flag |= BIT2;                   /* 0000 0100 */
    print_bin("set 0,1,2", flag);   /* 7: 0000 0111 */

    if (flag & BIT0)                /* & 로 특정 비트만 확인 */
        printf("The first LSB ON 0000 0001\n");
    else
        printf("The first LSB OFF\n");
    if (flag & BIT1)
        printf("The 2nd LSB ON 0000 0010\n");
    else
        printf("The 2nd LSB OFF\n");
    if (flag & BIT2)
        printf("The 3rd LSB ON 0000 0100\n");
    else
        printf("The 3rd LSB OFF\n");

    flag &= (unsigned char)~BIT1;   /* 비트 1만 끈다 */
    print_bin("clear 1", flag);
    flag ^= BIT0;                   /* 비트 0을 뒤집는다(1 -> 0) */
    print_bin("toggle 0", flag);
    flag ^= BIT0;                   /* 다시 뒤집는다(0 -> 1) */
    print_bin("toggle 0 again", flag);
    return 0;
}
