// sync4.v : 4비트 동기식 2진 카운터 (Lab 09 Part D)
//   cnt4_t : 17.10절 cnt3_t를 4비트로 늘린 것. T0 = 1, T1 = Q0, T2 = Q0·Q1, T3 = Q0·Q1·Q2 (17.5절)
//            T2, T3를 2입력 AND 체인으로 만든다(17.5.2절 (a)). 회로도의 AND inst5, inst9와 같다.
//   sync4  : sync4_sch.bdf(기존 6_3_syn_4bit_counter\...\4bits_counter.bdf)와 같은 핀의 보드용 top
//            회로도는 J = K = T인 JKFF 4개, 클럭은 네 플립플롭에 공통(상승 에지)
module cnt4_t (input clk, input clrn, output reg [3:0] q);
  wire t0 = 1'b1;
  wire t1 = q[0];
  wire t2 = t1 & q[1];                 // AND 체인 1단 = 회로도 inst5
  wire t3 = t2 & q[2];                 // AND 체인 2단 = 회로도 inst9
  always @(posedge clk or negedge clrn)
    if (!clrn) q <= 4'b0000;            // 비동기 클리어(액티브 로우)
    else       q <= q ^ {t3, t2, t1, t0};   // 각 비트를 자기 T 조건으로 XOR = 토글
endmodule

module sync4 (
    input  wire Cp,      // KEY[0] 뗄 때 상승 에지 → 1 증가
    input  wire ClrN,    // KEY[1] 누르면 0000
    output wire Qa,      // LEDR[0] LSB
    output wire Qb,      // LEDR[1]
    output wire Qc,      // LEDR[2]
    output wire Qd       // LEDR[3] MSB
);
    wire [3:0] q;
    cnt4_t u (.clk(Cp), .clrn(ClrN), .q(q));
    assign {Qd, Qc, Qb, Qa} = q;
endmodule
