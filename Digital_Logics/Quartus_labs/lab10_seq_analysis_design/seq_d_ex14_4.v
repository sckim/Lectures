// seq_d_ex14_4.v : 예제 14-4 회로 (D 플립플롭 2개, 상승 에지, 무어 출력)  Lab 10 Part A
//   D_A = x xor B'  (= XNOR(x, B))     D_B = A + x     z = A xor B
// seq_d_ex14_4_sch.bdf와 같은 연결이다. 인스턴스 이름 u_instN의 N이 회로도의 instN과 같다.
module seq_d_ex14_4 (
    input  wire CLK,    // KEY[0]  (뗄 때 0 -> 1, 상승 에지)
    input  wire ClrN,   // KEY[1]  누르면 0 -> A B = 00
    input  wire X,      // SW[0]
    output wire A,      // LEDR[5]
    output wire B,      // LEDR[4]
    output wire Z       // LEDR[0]
);
    wire DA = ~(X ^ B);     // inst1 XNOR : x xor B' = (x xor B)'
    wire DB = A | X;        // inst2 OR2
    assign Z = A ^ B;       // inst3 XOR  : 상태만으로 정해진다(무어)
    d_ff_c u_inst4 (.CLK(CLK), .CLRN(ClrN), .D(DA), .Q(A));   // inst4 DFF (PRN = VCC)
    d_ff_c u_inst5 (.CLK(CLK), .CLRN(ClrN), .D(DB), .Q(B));   // inst5 DFF (PRN = VCC)
endmodule
