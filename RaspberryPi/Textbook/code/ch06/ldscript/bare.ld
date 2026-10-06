/*
 * bare.ld : 6.7절  강의 슬라이드의 링커 스크립트 예를 GNU ld 문법에 맞게 고친 것
 *
 *   ROM(플래시) 0x00000000 부터 64 KiB : 코드와 상수, .data의 초기값
 *   RAM         0x00800000 부터 32 KiB : 실행 중에 쓰는 변수(.data, .bss)
 */
ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
    RAM (rwx) : ORIGIN = 0x00800000, LENGTH = 32K
}

SECTIONS
{
    /* 코드와 읽기 전용 상수는 ROM에 놓고 ROM에서 실행한다 */
    .text :
    {
        *(.text*)
        *(.rodata*)
    } > ROM

    /* .data: 실행 주소(VMA)는 RAM, 저장 주소(LMA)는 ROM (> RAM AT> ROM)
     * 시작 코드가 전원을 켤 때 ROM의 초기값을 RAM으로 복사해야 한다 */
    .data :
    {
        _data_start = .;
        *(.data*)
        _data_end = .;
    } > RAM AT> ROM
    _data_load = LOADADDR(.data);

    /* .bss: RAM에 자리만 잡는다. 파일에는 내용이 없고 시작 코드가 0으로 채운다 */
    .bss (NOLOAD) :
    {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > RAM

    /* 이 데모에서 필요 없는 섹션은 버린다 */
    /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}
