// johnson.v : 존슨 카운터 (Lab 08 Part D)
//   johnson3      : johnson3_sch.bdf(기존 counter_johnson_bdf\Johnscounter.bdf)와 같은 3비트 존슨 카운터
//                   D 플립플롭 3개 + NOT 1개. 12.8.8절 예제 12-12 (Q2 = 첫 단)
//   johnson4      : 18.10절의 4비트 존슨 카운터 그대로 (동기 리셋 rst = 1)
//   johnson4_fix  : 18.3.4절 [정리자 주]의 수정 식 DC = (QA + QC)·QB 를 넣은 것
//   johnson4_top  : 보드용 top. 시작값 로드(LDN)와 수정 식 선택(FIX)을 더했다

// 3비트 존슨 카운터: D(Q2) = Q0', D(Q1) = Q2, D(Q0) = Q1
module johnson3 (
    input  wire Clk,     // KEY[0] 뗄 때 상승 에지
    input  wire ClrN,    // KEY[1] 누르면 000 (비동기 클리어)
    output wire Q2,      // LEDR[2] 첫 단
    output wire Q1,      // LEDR[1]
    output wire Q0       // LEDR[0] 마지막 단 (반전해서 첫 단으로 돌아감)
);
    reg [2:0] q;                              // q = {Q2, Q1, Q0}
    always @(posedge Clk or negedge ClrN)
        if (!ClrN) q <= 3'b000;
        else       q <= {~q[0], q[2:1]};      // 회로도: inst(Q2) ← NOT inst3 ← Q0, inst1(Q1) ← Q2, inst2(Q0) ← Q1
    assign {Q2, Q1, Q0} = q;
endmodule

// 4비트 존슨 카운터 (18.10절)
module johnson4 (input clk, input rst, output reg [3:0] q);
  always @(posedge clk)
    if (rst) q <= 4'b0000;
    else     q <= {~q[0], q[3:1]};    // QD′을 QA로
endmodule

// 4비트 존슨 카운터 + 미사용 상태 수정 (18.3.4절): q = {QA, QB, QC, QD}
//   DA = QD′, DB = QA, DC = (QA + QC)·QB, DD = QC
module johnson4_fix (input clk, input rst, output reg [3:0] q);
  always @(posedge clk)
    if (rst) q <= 4'b0000;
    else     q <= {~q[0], q[3], (q[3] | q[1]) & q[2], q[1]};
endmodule

// 보드용 top
module johnson4_top (
    input  wire       CLK,    // KEY[0] 뗄 때 상승 에지
    input  wire       RSTN,   // KEY[1] 누르면 0000 (비동기)
    input  wire       LDN,    // KEY[2] 누른 채 KEY[0]을 누르고 떼면 D를 싣는다 (동기 로드)
    input  wire       FIX,    // SW[9]  0 = 원래 존슨 카운터, 1 = 수정 식
    input  wire [3:0] D,      // SW[3:0] 시작값 {QA, QB, QC, QD}
    output reg  [3:0] Q       // LEDR[3:0] = {QA, QB, QC, QD}
);
    wire dc = FIX ? ((Q[3] | Q[1]) & Q[2]) : Q[2];      // C단 입력만 다르다
    always @(posedge CLK or negedge RSTN)
        if (!RSTN)     Q <= 4'b0000;
        else if (!LDN) Q <= D;
        else           Q <= {~Q[0], Q[3], dc, Q[1]};
endmodule
