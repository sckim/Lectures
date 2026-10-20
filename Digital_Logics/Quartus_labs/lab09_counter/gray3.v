// gray3.v : 3비트 Gray 코드 카운터 (Lab 09 Part F)
//   gray3    : 18.10절 코드 그대로 (상태도를 case 문으로 옮긴 것, 동기 리셋)
//   gray3_jk : gray3_sch.bdf(기존 Gray_counter\graycode.bdf)를 그대로 옮긴 보드용 top
//              74138(3×8 디코더) + NOT 8개 + OR 2개 + JKFF 3개 (18.4.4–18.4.5절)
//              J2 = m2, K2 = m4, J1 = m1, K1 = m7, J0 = m0 + m6, K0 = m3 + m5
//   회로도에는 클리어가 없다(PRN, CLRN = VCC). 전원을 켜면 Cyclone V의 레지스터가 0이므로 000에서 시작한다.
//   gray3_jk의 reg 선언에 붙인 = 1'b0은 그 전원 투입 값을 적은 것이다.

// 3비트 Gray 코드 카운터: 상태도를 case 문으로 그대로 옮긴 것
module gray3 (input clk, input rst, output reg [2:0] g);
  always @(posedge clk)
    if (rst) g <= 3'b000;
    else case (g)
      3'b000: g <= 3'b001;  3'b001: g <= 3'b011;
      3'b011: g <= 3'b010;  3'b010: g <= 3'b110;
      3'b110: g <= 3'b111;  3'b111: g <= 3'b101;
      3'b101: g <= 3'b100;  default: g <= 3'b000;   // 100 → 000
    endcase
endmodule

module gray3_jk (
    input  wire       CLK,     // KEY[0] 뗄 때 상승 에지
    output wire [2:0] Q        // LEDR[2:0], Q[2] = MSB
);
    reg q2 = 1'b0, q1 = 1'b0, q0 = 1'b0;           // 전원 투입 값 000
    wire [7:0] m = 8'b0000_0001 << {q2, q1, q0};   // 74138(A = Q0, B = Q1, C = Q2) + NOT: m[i] = 1이면 상태 i
    wire j2 = m[2],        k2 = m[4];              // 회로도 NOT inst6, inst8
    wire j1 = m[1],        k1 = m[7];              // 회로도 NOT inst5, inst11
    wire j0 = m[0] | m[6], k0 = m[3] | m[5];       // 회로도 OR inst12(m0, m6), inst13(m3, m5)
    always @(posedge CLK) begin                    // JKFF 3개: Q+ = JQ' + K'Q
        q2 <= (j2 & ~q2) | (~k2 & q2);             // 회로도 inst
        q1 <= (j1 & ~q1) | (~k1 & q1);             // 회로도 inst1
        q0 <= (j0 & ~q0) | (~k0 & q0);             // 회로도 inst2
    end
    assign Q = {q2, q1, q0};
endmodule
