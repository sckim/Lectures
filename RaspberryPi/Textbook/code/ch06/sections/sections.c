/*
 * sections.c : 실습 6-4  변수와 코드가 ELF의 어느 섹션에 들어가는지 확인
 *
 * 빌드 : make            (sections_base, sections_data, sections_bss 세 가지를 만든다)
 * 확인 : make compare    (size로 섹션 크기 비교, ls -l로 파일 크기 비교)
 *        nm -n sections_base | grep -E 'g_|s_|msg|main'
 *
 * -DADD_DATA : 초기값이 있는 큰 배열을 추가 → .data가 4000바이트 늘어난다
 * -DADD_BSS  : 초기값이 없는 큰 배열을 추가 → .bss가 4000바이트 늘어난다
 */
#include <stdio.h>

const char msg[] = "read-only message";    /* 상수 → .rodata */
int g_init = 7;                            /* 0이 아닌 초기값이 있는 전역 → .data */
int g_zero = 0;                            /* 0으로 초기화한 전역 → .bss */
int g_uninit;                              /* 초기값 없는 전역 → .bss */
static int s_count = 3;                    /* static 전역(파일 안에서만 보임) → .data */

#ifdef ADD_DATA
int g_table[1000] = { 1 };                 /* 4000바이트, 첫 원소만 1 → .data */
#endif
#ifdef ADD_BSS
int g_buffer[1000];                        /* 4000바이트, 초기값 없음 → .bss */
#endif

int main(void)                             /* 함수의 기계어 → .text */
{
    int local = 5;                         /* 지역 변수 → 실행 중 스택(파일에는 없다) */
    static int s_calls;                    /* static 지역 변수 → .bss (값이 유지된다) */

    s_calls++;
    s_count++;
    printf("%s: g_init=%d g_zero=%d g_uninit=%d s_count=%d local=%d s_calls=%d\n",
           msg, g_init, g_zero, g_uninit, s_count, local, s_calls);
#ifdef ADD_DATA
    printf("g_table[0]=%d\n", g_table[0]);
#endif
#ifdef ADD_BSS
    printf("g_buffer[0]=%d\n", g_buffer[0]);
#endif
    return 0;
}
