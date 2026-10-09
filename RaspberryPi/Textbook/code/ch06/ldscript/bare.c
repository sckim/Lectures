/*
 * bare.c : 6.7절  링커 스크립트로 섹션을 원하는 주소에 배치해 보기 (실행하지 않는다)
 *
 * OS 없이(bare-metal) 돌아가는 펌웨어를 흉내 낸 코드이다. 표준 라이브러리를 쓰지 않으므로
 * -ffreestanding으로 컴파일하고, gcc 대신 ld를 직접 불러 bare.ld로 링크한다.
 *
 * 빌드 : make        → bare.elf 생성, objdump -h로 VMA/LMA 확인
 * 주의 : Linux에서 실행하는 프로그램이 아니다. 섹션 배치만 관찰한다.
 */
const char banner[] = "bare-metal demo";   /* .rodata → ROM */
int boot_count = 1;                          /* .data   → RAM에서 실행, 초기값은 ROM에 보관 */
int scratch[16];                             /* .bss    → RAM, 0으로 채워야 함 */

void _start(void)                            /* 리셋 후 처음 실행된다고 가정한 함수 */
{
    boot_count++;
    scratch[0] = banner[0];
    for (;;)
        ;                                    /* 펌웨어는 끝나지 않는다 */
}
