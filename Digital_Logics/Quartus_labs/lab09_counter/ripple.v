// ripple.v : 리플(비동기) 카운터 (Lab 09 Part B, C)
//   tff_neg, ripple4, ripple_mod10 : 13.9절 코드 그대로
//   ripple3      : ripple3_sch.bdf(기존 RippleCounter\3bit_ripple\ripple_counter.bdf)와 같은 핀의 3비트 업 카운터
//   ripple3_down : ripple3_down_sch.bdf(기존 3bit_ripple_down.bdf)와 같은 3비트 다운 카운터 (Q̄에서 읽기, 13.3.1절)
// 회로도는 J = K = 1인 JKFF(상승 에지) 앞에 NOT을 붙여 하강 에지로 쓴다. tff_neg와 같은 동작이다.
// [정리자 주] 플립플롭 출력을 다음 플립플롭의 클럭으로 쓰는 구조이다. FPGA 설계에서는 피한다(13.9절).
//   여기서는 13장 학습을 위해 일부러 그대로 쓴다.

// 하강 에지 T 플립플롭(T = 1 고정), 액티브 로우 비동기 클리어
module tff_neg (
    input  wire clk, clrn,
    output reg  q
);
    always @(negedge clk or negedge clrn)
        if (!clrn) q <= 1'b0;
        else       q <= ~q;              // 트리거마다 토글
endmodule

// 4비트 리플 업 카운터: 앞 단의 Q가 다음 단의 클럭
module ripple4 (
    input  wire       clk, clrn,
    output wire [3:0] q                  // q[0] = QA(LSB)
);
    tff_neg f0 (.clk(clk),  .clrn(clrn), .q(q[0]));
    tff_neg f1 (.clk(q[0]), .clrn(clrn), .q(q[1]));
    tff_neg f2 (.clk(q[1]), .clrn(clrn), .q(q[2]));
    tff_neg f3 (.clk(q[2]), .clrn(clrn), .q(q[3]));
endmodule

// 10진(mod-10) 리플 카운터: 1010이 되는 순간 NAND로 비동기 클리어
module ripple_mod10 (
    input  wire       clk, rstn,
    output wire [3:0] q
);
    wire clrn = rstn & ~(q[3] & q[1]);   // QD·QB = 1이면 클리어(액티브 로우)
    ripple4 u (.clk(clk), .clrn(clrn), .q(q));
endmodule

// 3비트 리플 업 카운터 (보드용 top, 핀 이름은 ripple3_sch.bdf와 같다)
module ripple3 (
    input  wire       n_cp,   // KEY[0] 누르는 순간(1 → 0)이 하강 에지 → 1 증가
    input  wire       ClrN,   // KEY[1] 누르면 000
    output wire [2:0] Q       // LEDR[2:0], Q[0] = LSB
);
    tff_neg f0 (.clk(n_cp), .clrn(ClrN), .q(Q[0]));   // 회로도 NOT inst6 + JKFF inst
    tff_neg f1 (.clk(Q[0]), .clrn(ClrN), .q(Q[1]));   // 회로도 NOT inst7 + JKFF inst1
    tff_neg f2 (.clk(Q[1]), .clrn(ClrN), .q(Q[2]));   // 회로도 NOT inst8 + JKFF inst2
endmodule

// 3비트 리플 다운 카운터: 업 카운터 그대로, 출력만 Q̄에서 읽는다
module ripple3_down (
    input  wire       n_cp,
    input  wire       ClrN,
    output wire [2:0] Q       // = 7 − (업 카운트)
);
    wire [2:0] qi;                                     // 플립플롭 출력 (업 카운트)
    tff_neg f0 (.clk(n_cp),  .clrn(ClrN), .q(qi[0]));
    tff_neg f1 (.clk(qi[0]), .clrn(ClrN), .q(qi[1]));
    tff_neg f2 (.clk(qi[1]), .clrn(ClrN), .q(qi[2]));
    assign Q = ~qi;                                    // 회로도 NOT inst9, inst10, inst11
endmodule
