// bcd2seg.v : 1초마다 0–9를 세어 HEX0에 표시 (Lab 09 Part E-1)
// bcd2seg_sch.bdf(기존 5_Ripplecounter\BCD2SEG\bcd2seg.bdf)와 같은 연결이다.
//   CLOCK_50 → clkdiv(1 Hz) → 7490(10진 카운터) → 7447(BCD → 7세그먼트) → HEX0
//   7490 : ÷2(CLKA → QA)와 ÷5(CLKB → QB QC QD)가 들어 있는 비동기 카운터(18.5.1절).
//          QA를 CLKB에 이으면 QD QC QB QA가 0–9를 센다. 클럭은 하강 에지이다.
//          CLRA·CLRB(0으로 리셋)와 SET9A·SET9B(9로 셋)는 회로도에서 GND에 묶었다.
//   7447 : 출력이 액티브 로우라 공통 양극 HEX0에 그대로 잇는다(Lab 05 Part B와 같다).
// [정리자 주] 분주기 출력이 7490의 클럭이 되는 "여러 클럭" 구조이다. 1 Hz처럼 느린 회로에서는 문제없이
//   동작하지만(22.3.1절 [정리자 주]), 한 클럭으로 만든 Verilog 설계는 bcd_counter.v의 bcd_hex를 본다.

// 7490 10진 카운터의 동작 모델 (회로도의 7490 매크로 inst)
module ic7490 (
    input  wire CLKA, CLKB,          // 하강 에지
    input  wire CLRA, CLRB,          // 둘 다 1이면 0000 (비동기)
    input  wire SET9A, SET9B,        // 둘 다 1이면 1001 (비동기, 리셋보다 우선)
    output reg  QA = 1'b0,           // ÷2 단
    output reg  QB = 1'b0, QC = 1'b0, QD = 1'b0   // ÷5 단 (QD QC QB = 0–4)
);                                   // = 1'b0 : [정리자 주] 전원 투입 값 (리셋 단자를 GND에 묶었으므로)
    wire clr = CLRA & CLRB, set9 = SET9A & SET9B;
    always @(negedge CLKA or posedge clr or posedge set9)
        if (set9)     QA <= 1'b1;
        else if (clr) QA <= 1'b0;
        else          QA <= ~QA;
    always @(negedge CLKB or posedge clr or posedge set9)
        if (set9)     {QD, QC, QB} <= 3'b100;
        else if (clr) {QD, QC, QB} <= 3'd0;
        else          {QD, QC, QB} <= ({QD, QC, QB} == 3'd4) ? 3'd0 : {QD, QC, QB} + 3'd1;
endmodule

// 7447과 같은 글꼴의 BCD → 7세그먼트 디코더 (Lab 05 bcd7seg.v와 같은 표, 0 = 켜짐)
module seg7447 (
    input  wire [3:0] bcd,           // bcd[0] = 7447 A (LSB) … bcd[3] = D
    output reg  [6:0] seg            // seg[0] = OA(a) … seg[6] = OG(g)
);
    always @(*)
        case (bcd)            //   gfedcba
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000011;   // 7447: 6에 a 없음
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0011000;   // 7447: 9에 d 없음
            default: seg = 7'b1111111; // 10–15: 이 모델은 끔 (7490은 10 이상을 내지 않는다)
        endcase
endmodule

// 보드용 top (핀 이름은 bcd2seg_sch.bdf와 같다)
module bcd2seg #(parameter HALF = 25_000_000) (
    input  wire       CLOCK_50,      // PIN_AF14
    output wire [6:0] HEX0,          // HEX0[0] = a … HEX0[6] = g
    output wire [3:0] Q              // LEDR[3:0] = QD QC QB QA
);
    wire clk1;
    clkdiv  #(.HALF(HALF)) inst4 (.clk50(CLOCK_50), .rst(1'b0), .clk1(clk1));            // 회로도 inst4
    ic7490  inst  (.CLKA(clk1), .CLKB(Q[0]), .CLRA(1'b0), .CLRB(1'b0), .SET9A(1'b0), .SET9B(1'b0),
                   .QA(Q[0]), .QB(Q[1]), .QC(Q[2]), .QD(Q[3]));                         // 회로도 inst
    seg7447 inst1 (.bcd(Q), .seg(HEX0));                                                 // 회로도 inst1 (LT', RBI', BI' = VCC)
endmodule
