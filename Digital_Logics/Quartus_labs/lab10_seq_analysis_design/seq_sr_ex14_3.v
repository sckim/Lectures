// seq_sr_ex14_3.v : 예제 14-3 회로 (SR 플립플롭 2개, 밀리 출력)  Lab 10 Part B
//   S_A = x'B   R_A = xB'   S_B = xA'   R_B = x'A   y = xAB'
// 기존 회로도 Seq_Ex.bdf(seq_sr_ex14_3_sch.bdf)와 같은 연결이다. 원본 회로도의 SRFF는 상승 에지이다.
// (2023-2·2024-2 중간 기출 그림은 하강 에지였다. 상태표·상태도는 트리거 종류와 상관없이 같다. 14.4절 [정리자 주])
module seq_sr_ex14_3 (
    input  wire CLK,    // KEY[0]
    input  wire ClrN,   // KEY[1]
    input  wire X,      // SW[0]
    output wire Y,      // LEDR[0]
    output wire A,      // LEDR[5]
    output wire B       // LEDR[4]
);
    wire Xn = ~X;           // inst10 NOT
    wire An = ~A;           // NOT "Q_A" (인스턴스 이름이 Q_A인 NOT 게이트)
    wire Bn = ~B;           // NOT "Q_B"
    wire SA = Xn & B;       // inst2
    wire RA = X  & Bn;      // inst3
    wire SB = An & X;       // inst4
    wire RB = A  & Xn;      // inst5
    assign Y = X & A & Bn;  // inst  (AND3) : 입력 x가 출력에 들어간다(밀리)
    sr_ff_c u_FFA (.CLK(CLK), .CLRN(ClrN), .S(SA), .R(RA), .Q(A));   // F-FA (SRFF, PRN = VCC)
    sr_ff_c u_FFB (.CLK(CLK), .CLRN(ClrN), .S(SB), .R(RB), .Q(B));   // F-FB
endmodule
