@ enc_a32.s - A32(32비트 ARM) 명령어가 어떤 기계어가 되는지 확인한다
@ 실행: make enc32   (binutils-arm-linux-gnueabihf 패키지 필요)
        .arm
        .text
        sub     r0, r1, r2          @ R0 = R1 - R2
        subs    r0, r1, r2          @ 같은 뺄셈 + 플래그 갱신(S 비트)
        addgt   r0, r1, r2          @ GT 조건일 때만 실행(cond 필드)
        ldr     r0, [r4, r5]        @ R0 = 메모리[R4 + R5]
        str     r0, [r4, r5]        @ 메모리[R4 + R5] = R0
        mov     pc, lr              @ 옛 방식의 함수 복귀
        bx      lr                  @ 요즘 방식의 함수 복귀
        push    {r4, lr}            @ PUSH라는 이름(별칭)
        stmdb   sp!, {r4, lr}       @ 원래 이름: 위와 같은 기계어가 나온다
