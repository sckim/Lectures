// ttl_clock.v : 7490·7492·7447 디지털 시계 (Lab 12 Part C의 Verilog 버전)
//   기존 예제 6_Counter/Projects/Set_Clock_92/Set_Clock.bdf를 옮긴 ttl_clock_sch.bdf와 같은 연결이다.
//   인스턴스 이름 uN = 회로도의 instN.
//   [주의] 이 회로는 앞단 출력이 뒷단 클럭이 되는 리플(비동기) 구조이다(13장, 22.4.3절).
//          강의 회로를 그대로 옮긴 것이며, FPGA 설계의 권장 방식은 Part B(단일 클럭 + tick)이다.
//   SW[0] = 1 동작, 0 정지(분주기 리셋)   SW[1] 올렸다 내리면 분 +1   SW[2] 올렸다 내리면 시 +1
module ttl_clock (
    input  wire       Clock_50,
    input  wire [2:0] SW,
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
    wire [25:0] q;
    wire s1a, s1b, s1c, s1d;      // 초 일의 자리  (7490 u)
    wire s10a, s10b, s10c, s10d;  // 초 십의 자리  (7492 u5)
    wire m1a, m1b, m1c, m1d;      // 분 일의 자리  (7490 u32)
    wire m10a, m10b, m10c, m10d;  // 분 십의 자리  (7492 u6)
    wire h1a, h1b, h1c, h1d;      // 시 일의 자리  (7490 u40)
    wire h10a, h10b, h10c, h10d;  // 시 십의 자리  (7490 u41)
    wire clk_m, clk_h, clr_h;

    Mod50MHz u1 (.n_cp(Clock_50), .n_rd(SW[0]), .q(q));

    // 초: 7490(÷10) → 7492(÷6)
    ttl7490 u   (.CLKA(q[25]), .CLKB(s1a), .CLRA(1'b0), .CLRB(1'b0), .SET9A(1'b0), .SET9B(1'b0),
                 .QA(s1a), .QB(s1b), .QC(s1c), .QD(s1d));
    ttl7492 u5  (.CLKA(s1d), .CLKB(s10a), .CLRA(1'b0), .CLRB(1'b0),
                 .QA(s10a), .QB(s10b), .QC(s10c), .QD(s10d));
    // 분: 초 십의 자리 QC(5 → 6에서 떨어짐) OR SW[1]
    assign clk_m = s10c | SW[1];                                   // OR2 inst2
    ttl7490 u32 (.CLKA(clk_m), .CLKB(m1a), .CLRA(1'b0), .CLRB(1'b0), .SET9A(1'b0), .SET9B(1'b0),
                 .QA(m1a), .QB(m1b), .QC(m1c), .QD(m1d));
    ttl7492 u6  (.CLKA(m1d), .CLKB(m10a), .CLRA(1'b0), .CLRB(1'b0),
                 .QA(m10a), .QB(m10b), .QC(m10c), .QD(m10d));
    // 시: 분 십의 자리 QC OR SW[2], 7490 두 개, 24(0010 0100)에서 비동기 클리어
    assign clk_h = m10c | SW[2];                                   // OR2 inst3
    assign clr_h = h1c & h10b;                                     // AND2 inst7: 일의 자리 4, 십의 자리 2
    ttl7490 u40 (.CLKA(clk_h), .CLKB(h1a), .CLRA(clr_h), .CLRB(clr_h), .SET9A(1'b0), .SET9B(1'b0),
                 .QA(h1a), .QB(h1b), .QC(h1c), .QD(h1d));
    ttl7490 u41 (.CLKA(h1d), .CLKB(h10a), .CLRA(clr_h), .CLRB(clr_h), .SET9A(1'b0), .SET9B(1'b0),
                 .QA(h10a), .QB(h10b), .QC(h10c), .QD(h10d));

    // 표시: 7447 6개. 십의 자리 7492는 QA QB QC만 쓰고 D는 GND
    ttl7447 u27 (.D(s1d),  .C(s1c),  .B(s1b),  .A(s1a),
                 .OA(HEX0[0]), .OB(HEX0[1]), .OC(HEX0[2]), .OD(HEX0[3]), .OE(HEX0[4]), .OF(HEX0[5]), .OG(HEX0[6]));
    ttl7447 u29 (.D(1'b0), .C(s10c), .B(s10b), .A(s10a),
                 .OA(HEX1[0]), .OB(HEX1[1]), .OC(HEX1[2]), .OD(HEX1[3]), .OE(HEX1[4]), .OF(HEX1[5]), .OG(HEX1[6]));
    ttl7447 u35 (.D(m1d),  .C(m1c),  .B(m1b),  .A(m1a),
                 .OA(HEX2[0]), .OB(HEX2[1]), .OC(HEX2[2]), .OD(HEX2[3]), .OE(HEX2[4]), .OF(HEX2[5]), .OG(HEX2[6]));
    ttl7447 u37 (.D(1'b0), .C(m10c), .B(m10b), .A(m10a),
                 .OA(HEX3[0]), .OB(HEX3[1]), .OC(HEX3[2]), .OD(HEX3[3]), .OE(HEX3[4]), .OF(HEX3[5]), .OG(HEX3[6]));
    ttl7447 u43 (.D(h1d),  .C(h1c),  .B(h1b),  .A(h1a),
                 .OA(HEX4[0]), .OB(HEX4[1]), .OC(HEX4[2]), .OD(HEX4[3]), .OE(HEX4[4]), .OF(HEX4[5]), .OG(HEX4[6]));
    ttl7447 u45 (.D(h10d), .C(h10c), .B(h10b), .A(h10a),
                 .OA(HEX5[0]), .OB(HEX5[1]), .OC(HEX5[2]), .OD(HEX5[3]), .OE(HEX5[4]), .OF(HEX5[5]), .OG(HEX5[6]));
endmodule
