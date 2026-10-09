/*
 * stack_overflow.c : 실습 11-1(이어서)  재귀 호출로 스택을 다 쓰면 어떻게 되는가
 *
 * 회로 : 없음
 * 빌드 : gcc -Wall -O0 -o stack_overflow stack_overflow.c   (또는 make stack_overflow)
 *        -O0 : 최적화하면 컴파일러가 재귀를 반복문으로 바꿔(꼬리 호출 최적화) 스택이 자라지 않을 수 있다.
 * 실행 : ulimit -s                  현재 스택 한도(KiB) 확인
 *        ./stack_overflow           1000단계마다 깊이와 SP 근처 주소를 출력하다 Segmentation fault
 *        (ulimit -s 1024; ./stack_overflow)   괄호 = 하위 셸에서만 한도를 1 MiB로 줄여 실행
 *
 * 한 번 호출될 때마다 1 KiB 배열(지역 변수)이 스택에 쌓인다. 한도를 넘으면 커널이 SIGSEGV를 보낸다.
 */
#include <stdio.h>
#include <string.h>

static char *first_frame;           /* 첫 호출의 지역 변수 주소 (깊이 계산용) */

static void dive(int depth)
{
    char buf[1024];                 /* 호출마다 스택을 1 KiB씩 쓴다 */

    memset(buf, depth & 0xFF, sizeof(buf));   /* 실제로 써야 페이지가 할당된다 */
    if (first_frame == NULL)
        first_frame = buf;
    if (depth % 1000 == 0) {
        printf("depth %6d  buf=%p  사용한 스택 약 %ld KiB\n",
               depth, (void *)buf, (long)(first_frame - buf) / 1024);
        fflush(stdout);             /* 죽기 직전 출력이 버퍼에 남지 않도록 */
    }
    if (depth < 10000000)           /* 끝 조건(사실상 도달하지 않는다). 없으면 gcc가 무한 재귀 경고를 낸다 */
        dive(depth + 1);
    buf[0]++;                       /* 재귀 뒤에도 buf를 써서 꼬리 호출이 되지 않게 한다 */
}

int main(void)
{
    dive(0);
    return 0;                       /* 여기까지 오지 않는다 */
}
