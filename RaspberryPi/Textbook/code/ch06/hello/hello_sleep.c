/*
 * hello_sleep.c : 실습 6-1  1초마다 경과 시간을 출력하는 무한 루프
 *
 * 빌드 : gcc -Wall -o hello_sleep hello_sleep.c
 * 실행 : ./hello_sleep        (Ctrl+C로 종료, ./hello_sleep & 로 백그라운드 실행)
 *
 * 원본 : Codes/hello_sleep.c (Raspberry Pi Codes §2.1). h2.c, h3.c는 같은 코드에
 *        시작값만 다르므로 합쳤다. void main을 int main으로 고쳤다.
 *        #include <unistd.h>를 지우고 빌드하면 6.4절의 "암시적 선언" 경고를 볼 수 있다.
 */
#include <stdio.h>
#include <unistd.h>     /* sleep() 선언 */

int main(void)
{
    int sec = 0;

    printf("Hello, world!\n");
    while (1) {
        printf("Elapsed time: %3d seconds\n", sec);
        fflush(stdout);  /* 파이프·파일로 출력을 보낼 때도 바로 보이게 */
        sleep(1);
        sec++;
    }
    return 0;            /* 도달하지 않는다 */
}
