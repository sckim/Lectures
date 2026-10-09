/*
 * no_unistd.c : 6.4절  헤더를 빠뜨렸을 때(선언 없음)의 경고 관찰
 *
 * sleep()을 쓰면서 #include <unistd.h>를 일부러 뺐다.
 * 빌드 : gcc -Wall -o no_unistd no_unistd.c
 *        → warning: implicit declaration of function 'sleep'
 *        gcc 12는 경고만 내고 실행 파일을 만들지만, gcc 14부터는 오류로 바뀌었다.
 * 고치기 : 아래 주석 처리된 #include 줄의 주석을 푼다.
 */
#include <stdio.h>
/* #include <unistd.h> */

int main(void)
{
    printf("1초 쉽니다...\n");
    sleep(1);
    printf("끝\n");
    return 0;
}
