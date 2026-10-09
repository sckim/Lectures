/*
 * memory_layout.c : 실습 11-1  프로세스 메모리 구조(text, rodata, data, bss, heap, mmap, stack) 확인
 *
 * 회로 : 없음 (GPIO를 쓰지 않는다. PC(WSL)에서도 실행된다)
 * 빌드 : gcc -Wall -O0 -o memory_layout memory_layout.c     (또는 make memory_layout)
 * 실행 : ./memory_layout                 주소 출력 + /proc/self/maps
 *        ./memory_layout nomaps          주소만 출력 (여러 번 실행해 주소 비교용)
 *        setarch $(uname -m) -R ./memory_layout nomaps   주소 무작위화(ASLR)를 끄고 실행
 *
 * 원본 : Raspberry Pi Codes §4.1.6 memory_layout.c
 * 고친 점
 *   1) char local2 = 222 는 char가 signed인 x86에서 -34가 되고 경고가 난다.
 *      (ARM의 char는 unsigned라서 경고가 없다. 2장 2.18.3절) -> unsigned char로 바꿨다.
 *   2) .rodata(문자열 상수, const 전역)와 큰 malloc(256 KiB)을 추가했다.
 *      큰 할당은 [heap]이 아니라 mmap 영역에 놓이는 것을 확인하기 위해서이다.
 *   3) 마지막에 /proc/self/maps를 출력해 주소가 어느 영역에 속하는지 직접 맞춰 본다.
 *   4) -O0으로 빌드한다. 최적화하면 show_stack()이 main에 합쳐져(inline) 스택 프레임이 사라질 수 있다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int global_init = 100;              /* .data : 0이 아닌 초기값이 있는 전역 변수 */
int global_uninit;                  /* .bss  : 초기값이 없는 전역 변수 (0으로 시작) */
int global_zero = 0;                /* .bss  : 0으로 초기화한 전역 변수도 .bss */
const int global_const = 7;         /* .rodata : 읽기 전용 상수 */
const char *message = "hello";      /* "hello"는 .rodata, 포인터 변수 message는 .data */

static void print_maps(void)
{
    char line[512];
    FILE *fp = fopen("/proc/self/maps", "r");

    if (fp == NULL) {
        perror("/proc/self/maps");
        return;
    }
    printf("=== /proc/self/maps ===\n");
    while (fgets(line, sizeof(line), fp) != NULL)
        fputs(line, stdout);
    fclose(fp);
}

void show_stack(int a, int b, int c)
{
    unsigned char local1 = 111;
    unsigned char local2 = 222;
    char *heap_ptr = malloc(100);

    printf("[Inside show_stack()]\n");
    printf("  parameter a     : %p\n", (void *)&a);
    printf("  parameter b     : %p\n", (void *)&b);
    printf("  parameter c     : %p\n", (void *)&c);
    printf("  local1          : %p\n", (void *)&local1);
    printf("  local2          : %p\n", (void *)&local2);
    printf("  local heap_ptr  : %p\n\n", (void *)heap_ptr);

    free(heap_ptr);
}

int main(int argc, char *argv[])
{
    int stack_var1 = 10;
    int stack_var2 = 20;
    int stack_var3 = 30;
    static int static_var = 20;              /* 함수 안에 있어도 static이면 .data */
    char *heap_ptr = malloc(100);            /* 작은 할당: [heap] */
    char *big_ptr = malloc(256 * 1024);      /* 큰 할당(256 KiB): 별도의 mmap 영역 */

    printf("=== Memory Layout ===\n\n");

    printf("[Code Section (.text)]\n");
    printf("  main()          : %p\n", (void *)main);
    printf("  show_stack()    : %p\n\n", (void *)show_stack);

    printf("[Read-only Data (.rodata)]\n");
    printf("  global_const    : %p\n", (void *)&global_const);
    printf("  \"hello\"         : %p\n\n", (void *)message);

    printf("[Data Section (.data)]\n");
    printf("  global_init     : %p\n", (void *)&global_init);
    printf("  static_var      : %p\n", (void *)&static_var);
    printf("  message (ptr)   : %p\n\n", (void *)&message);

    printf("[BSS Section (.bss)]\n");
    printf("  global_uninit   : %p\n", (void *)&global_uninit);
    printf("  global_zero     : %p\n\n", (void *)&global_zero);

    printf("[Heap]\n");
    printf("  main heap_ptr   : %p  (100 B)\n", (void *)heap_ptr);
    printf("  main big_ptr    : %p  (256 KiB, mmap)\n\n", (void *)big_ptr);

    printf("[Stack in main()]\n");
    printf("  stack_var1      : %p\n", (void *)&stack_var1);
    printf("  stack_var2      : %p\n", (void *)&stack_var2);
    printf("  stack_var3      : %p\n\n", (void *)&stack_var3);

    show_stack(1, 2, 3);

    if (!(argc > 1 && strcmp(argv[1], "nomaps") == 0))
        print_maps();

    free(big_ptr);
    free(heap_ptr);
    return 0;
}
