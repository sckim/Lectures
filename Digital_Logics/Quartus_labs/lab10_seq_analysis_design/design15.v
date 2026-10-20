// design15.v : 예제 15-2의 상태도를 JK(예제 15-2), D(예제 15-3), T(예제 15-4)로 설계한 결과  Lab 10 Part C
//   상태도: 00 -1-> 01 -0-> 10 -1-> 11 -1-> 00, 그 밖의 입력은 제자리
//   JK : JA = Bx'          KA = Bx          JB = x           KB = A xnor x
//   D  : DA = AB' + Bx'    DB = A'x + B'x + ABx'
//   T  : TA = A'Bx' + ABx  TB = B'x + Ax + A'Bx'
// 보드용 top design15_jk_d는 회로도 design15_jk_d_sch.bdf와 같다(JK와 D를 나란히). T는 테스트벤치에서만 쓴다.

module ex15_jk (input wire CLK, ClrN, X, output wire A, B);
    wire JA = B & ~X;               // inst1
    wire KA = B &  X;               // inst2
    wire JB = X;                    // 선 하나
    wire KB = ~(A ^ X);             // inst3 XNOR
    jk_ff_c u_a (.CLK(CLK), .CLRN(ClrN), .J(JA), .K(KA), .Q(A));    // inst11
    jk_ff_c u_b (.CLK(CLK), .CLRN(ClrN), .J(JB), .K(KB), .Q(B));    // inst12
endmodule

module ex15_d (input wire CLK, ClrN, X, output wire A, B);
    wire DA = (A & ~B) | (B & ~X);                      // inst4, inst5 -> inst9 (OR2)
    wire DB = (~A & X) | (~B & X) | (A & B & ~X);       // inst6, inst7, inst8 -> inst10 (OR3)
    d_ff_c u_a (.CLK(CLK), .CLRN(ClrN), .D(DA), .Q(A));             // inst13
    d_ff_c u_b (.CLK(CLK), .CLRN(ClrN), .D(DB), .Q(B));             // inst14
endmodule

module ex15_t (input wire CLK, ClrN, X, output wire A, B);
    wire TA = (~A & B & ~X) | (A & B & X);
    wire TB = (~B & X) | (A & X) | (~A & B & ~X);
    t_ff_c u_a (.CLK(CLK), .CLRN(ClrN), .T(TA), .Q(A));
    t_ff_c u_b (.CLK(CLK), .CLRN(ClrN), .T(TB), .Q(B));
endmodule

// 보드용 top : 같은 x, 같은 클럭을 받는 JK 설계와 D 설계
module design15_jk_d (
    input  wire CLK,    // KEY[0]
    input  wire ClrN,   // KEY[1]
    input  wire X,      // SW[0]
    output wire A_JK,   // LEDR[5]
    output wire B_JK,   // LEDR[4]
    output wire A_D,    // LEDR[7]
    output wire B_D     // LEDR[6]
);
    ex15_jk u_jk (.CLK(CLK), .ClrN(ClrN), .X(X), .A(A_JK), .B(B_JK));
    ex15_d  u_d  (.CLK(CLK), .ClrN(ClrN), .X(X), .A(A_D),  .B(B_D));
endmodule
