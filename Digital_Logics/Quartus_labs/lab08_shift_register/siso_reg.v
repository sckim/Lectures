// siso_reg.v : 4비트 SISO(겸 SIPO) 시프트 레지스터 (Lab 08 Part A)
// siso_reg_sch.bdf(기존 SISO_Register.bdf)와 같은 동작이다.
//   - DFFE 4개, 상승 에지, 클럭 공통            12.2.1절
//   - Shift = 1일 때만 시프트, 0이면 유지      12.2.4절 시프트 인에이블
//   - ClrN = 0이면 클럭과 상관없이 0000         액티브 로우 비동기 클리어
//   - Q3 = QA(첫 단, SI가 들어가는 곳) ... Q0 = QD(마지막 단, 직렬 출력)
// 12.9절 siso4에 "else if (Shift)" 한 줄을 더한 것과 같다.
module siso_reg (
    input  wire SI,       // SW[0]  직렬 입력
    input  wire Shift,    // SW[1]  1 = 시프트, 0 = 유지
    input  wire Clock,    // KEY[0] 누르면 0, 떼면 1 → 뗄 때가 상승 에지
    input  wire ClrN,     // KEY[1] 누르면 0 → 비동기 클리어
    output wire Q3,       // LEDR[3] QA
    output wire Q2,       // LEDR[2] QB
    output wire Q1,       // LEDR[1] QC
    output wire Q0        // LEDR[0] QD (직렬 출력)
);
    reg [3:0] q;          // q[3] = Q3 = QA
    always @(posedge Clock or negedge ClrN)
        if (!ClrN)      q <= 4'b0000;
        else if (Shift) q <= {SI, q[3:1]};   // QA ← SI, QB ← QA, QC ← QB, QD ← QC
                                             // Shift = 0이면 대입 없음 → 유지
    assign {Q3, Q2, Q1, Q0} = q;
endmodule
