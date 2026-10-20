// ttl_parts.v : 7490, 7492, 7447의 동작 모델 (Lab 12 Part C의 Verilog 버전용)
//   회로도(ttl_clock_sch.bdf)는 Quartus maxplus2 라이브러리의 7490, 7492, 7447 매크로를 쓴다.
//   Verilog 이름은 숫자로 시작할 수 없으므로 ttl7490 등으로 지었다. 단자 이름은 매크로와 같다.
//   - 7490: CLKA → QA (÷2), CLKB → QB QC QD (÷5, 000 → 001 → 010 → 011 → 100). 하강 에지.
//           CLRA·CLRB 둘 다 1이면 0000, SET9A·SET9B 둘 다 1이면 1001 (SET9가 우선). 비동기.
//           QA를 CLKB에 이으면 0..9를 세는 BCD 카운터이다(13장).
//   - 7492: CLKA → QA (÷2), CLKB → QB QC QD (÷6, QD QC QB = 000 → 001 → 010 → 100 → 101 → 110).
//           QA를 CLKB에 이으면 QC QB QA가 0..5를 두 번 세고(0..11), QC는 5 → 6, 11 → 0에서 떨어진다.
//   - 7447: BCD → 7세그먼트, 출력 액티브 로우 {OG..OA}. 6은 a 없이, 9는 d 없이 (8.8.4절, Lab 05 bcd7seg).
//           LTN, RBIN, BIN은 회로도에서 모두 VCC이므로 모델에서는 쓰지 않는다.
//   레지스터는 0으로 시작한다(FPGA 전원 투입 값). 회로도의 초·분 카운터는 클리어 단자가 GND라
//   리셋이 없고, 전원을 켠 순간의 0에서 시작한다.
module ttl7490 (
    input  wire CLKA, CLKB, CLRA, CLRB, SET9A, SET9B,
    output wire QA, QB, QC, QD
);
    reg qa = 1'b0;                   // 전원 투입 값 0 (선언에서 초기화: 시작 순간 x → 0 에지가 생기지 않는다)
    reg [2:0] qdcb = 3'b000;         // {QD, QC, QB}
    assign QA = qa;
    assign {QD, QC, QB} = qdcb;
    wire r0 = CLRA & CLRB;
    wire r9 = SET9A & SET9B;
    always @(negedge CLKA or posedge r0 or posedge r9)
        if      (r9) qa <= 1'b1;
        else if (r0) qa <= 1'b0;
        else         qa <= ~qa;
    always @(negedge CLKB or posedge r0 or posedge r9)
        if      (r9) qdcb <= 3'b100;
        else if (r0) qdcb <= 3'b000;
        else         qdcb <= (qdcb == 3'b100) ? 3'b000 : qdcb + 3'b001;
endmodule

module ttl7492 (
    input  wire CLKA, CLKB, CLRA, CLRB,
    output wire QA, QB, QC, QD
);
    reg qa = 1'b0;
    reg [2:0] qdcb = 3'b000;         // {QD, QC, QB}
    assign QA = qa;
    assign {QD, QC, QB} = qdcb;
    wire r0 = CLRA & CLRB;
    always @(negedge CLKA or posedge r0)
        if (r0) qa <= 1'b0;
        else    qa <= ~qa;
    always @(negedge CLKB or posedge r0)
        if (r0) qdcb <= 3'b000;
        else case (qdcb)
            3'b000: qdcb <= 3'b001;
            3'b001: qdcb <= 3'b010;
            3'b010: qdcb <= 3'b100;
            3'b100: qdcb <= 3'b101;
            3'b101: qdcb <= 3'b110;
            default: qdcb <= 3'b000;   // 110 → 000
        endcase
endmodule

module ttl7447 (
    input  wire D, C, B, A,
    output wire OA, OB, OC, OD, OE, OF, OG
);
    reg [6:0] seg;                    // {g, f, e, d, c, b, a}, 0 = 켜짐
    always @(*)
        case ({D, C, B, A})
            4'd0: seg = 7'b1000000;   4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;   4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;   4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000011;   4'd7: seg = 7'b1111000;   // 6: a 없음
            4'd8: seg = 7'b0000000;   4'd9: seg = 7'b0011000;   // 9: d 없음
            default: seg = 7'b1111111;                         // 10..15: 이 모델은 끔
        endcase
    assign {OG, OF, OE, OD, OC, OB, OA} = seg;
endmodule
