// enc_a64.s - A64 명령어가 어떤 32비트 기계어가 되는지 확인한다
// 실행: make enc   (Raspberry Pi OS 64비트의 기본 as/objdump 사용)
        .text
        sub     w0, w1, w2      // W0 = W1 - W2 (32비트)
        sub     x0, x1, x2      // X0 = X1 - X2 (64비트)
        ldr     w0, [x4, x5]    // W0 = 메모리[X4 + X5]
        str     w0, [x4, x5]    // 메모리[X4 + X5] = W0
        ret                     // PC = X30(LR)로 복귀
