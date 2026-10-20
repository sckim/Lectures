// seq_jk_ex14_6.v : 예제 14-6 회로 (JK 플립플롭 2개, 출력 없음)  Lab 10 Part B
//   J_A = Bx'   K_A = B'x   J_B = A'x   K_B = Ax'
// 예제 15-6 (나)에서 예제 14-3의 상태 방정식을 JK 꼴로 맞추어 얻은 식과 같다. 상태표가 예제 14-3과 같아야 한다.
// seq_jk_ex14_6_sch.bdf와 같은 연결이다.
module seq_jk_ex14_6 (
    input  wire CLK,    // KEY[0]
    input  wire ClrN,   // KEY[1]
    input  wire X,      // SW[0]
    output wire A,      // LEDR[5]
    output wire B       // LEDR[4]
);
    wire Xn = ~X, An = ~A, Bn = ~B;   // not_X, not_A, not_B (JKFF 프리미티브에는 Q'이 없다)
    wire JA = B  & Xn;      // inst1
    wire KA = Bn & X;       // inst2
    wire JB = An & X;       // inst3
    wire KB = A  & Xn;      // inst4
    jk_ff_c u_inst5 (.CLK(CLK), .CLRN(ClrN), .J(JA), .K(KA), .Q(A));
    jk_ff_c u_inst6 (.CLK(CLK), .CLRN(ClrN), .J(JB), .K(KB), .Q(B));
endmodule
