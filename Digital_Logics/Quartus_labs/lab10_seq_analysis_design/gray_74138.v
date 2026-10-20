// gray_74138.v : 예제 16-4 3비트 Gray 코드 카운터 (JK 플립플롭 3개 + 3x8 디코더 74138)  Lab 10 Part D
//   순서 000 -> 001 -> 011 -> 010 -> 110 -> 111 -> 101 -> 100 -> 000
//   JA = Y2  KA = Y4  JB = Y1  KB = Y7  JC = Y0 + Y6  KC = Y3 + Y5   (A = Q[2] MSB, C = Q[0] LSB)
// gray_74138은 회로도 gray_74138_sch.bdf(기존 seq_decoder.bdf)와 같은 "출력마다 NOT" 방식이다.
// gray_74138_nand는 같은 회로를 NAND로 줄인 것, gray_74138_swap은 선택 입력 비트 순서를 일부러 거꾸로
// 연결한 것이다(둘 다 테스트벤치에서만 쓴다).

// 74138 : 선택 입력 A(LSB)·B·C(MSB), 인에이블 G1(액티브 하이)·G2AN·G2BN(액티브 로우), 출력 Y0N–Y7N(액티브 로우)
module ttl_74138 (
    input  wire A, B, C, G1, G2AN, G2BN,
    output wire [7:0] YN        // YN[i] = Y(i)N
);
    wire en = G1 & ~G2AN & ~G2BN;
    assign YN = en ? ~(8'b0000_0001 << {C, B, A}) : 8'hFF;
endmodule

module gray_74138 (
    input  wire CLK,        // KEY[0]
    input  wire ClrN,       // KEY[1]  (원본 회로도는 CLRN이 VCC였다. 초기화를 위해 핀으로 뺐다)
    output wire [2:0] Q     // LEDR[2:0]  Q[2] = A, Q[1] = B, Q[0] = C
);
    wire [7:0] YN;
    wire [7:0] Y = ~YN;                                      // inst15–inst22 : 출력마다 NOT
    ttl_74138 u_inst14 (.A(Q[0]), .B(Q[1]), .C(Q[2]), .G1(1'b1), .G2AN(1'b0), .G2BN(1'b0), .YN(YN));
    wire JC = Y[0] | Y[6];                                   // inst4 OR2
    wire KC = Y[3] | Y[5];                                   // inst5 OR2
    jk_ff_c u_inst  (.CLK(CLK), .CLRN(ClrN), .J(Y[2]), .K(Y[4]), .Q(Q[2]));   // A
    jk_ff_c u_inst2 (.CLK(CLK), .CLRN(ClrN), .J(Y[1]), .K(Y[7]), .Q(Q[1]));   // B
    jk_ff_c u_inst3 (.CLK(CLK), .CLRN(ClrN), .J(JC),   .K(KC),   .Q(Q[0]));   // C
endmodule

// NAND 방식: 액티브 로우 출력 둘을 OR하는 것은 NAND 하나와 같다 (Y0 + Y6 = (Y0N · Y6N)')
module gray_74138_nand (input wire CLK, ClrN, output wire [2:0] Q);
    wire [7:0] YN;
    ttl_74138 u_dec (.A(Q[0]), .B(Q[1]), .C(Q[2]), .G1(1'b1), .G2AN(1'b0), .G2BN(1'b0), .YN(YN));
    jk_ff_c u_a (.CLK(CLK), .CLRN(ClrN), .J(~YN[2]), .K(~YN[4]), .Q(Q[2]));
    jk_ff_c u_b (.CLK(CLK), .CLRN(ClrN), .J(~YN[1]), .K(~YN[7]), .Q(Q[1]));
    jk_ff_c u_c (.CLK(CLK), .CLRN(ClrN), .J(~(YN[0] & YN[6])), .K(~(YN[3] & YN[5])), .Q(Q[0]));
endmodule

// 잘못 연결한 예: 최상위 비트 Q[2]를 74138의 A(LSB)에, Q[0]을 C(MSB)에 거꾸로 연결 (16.2.3절 [정리자 주])
module gray_74138_swap (input wire CLK, ClrN, output wire [2:0] Q);
    wire [7:0] YN;
    wire [7:0] Y = ~YN;
    ttl_74138 u_dec (.A(Q[2]), .B(Q[1]), .C(Q[0]), .G1(1'b1), .G2AN(1'b0), .G2BN(1'b0), .YN(YN));
    jk_ff_c u_a (.CLK(CLK), .CLRN(ClrN), .J(Y[2]), .K(Y[4]), .Q(Q[2]));
    jk_ff_c u_b (.CLK(CLK), .CLRN(ClrN), .J(Y[1]), .K(Y[7]), .Q(Q[1]));
    jk_ff_c u_c (.CLK(CLK), .CLRN(ClrN), .J(Y[0] | Y[6]), .K(Y[3] | Y[5]), .Q(Q[0]));
endmodule
