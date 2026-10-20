// tb_bcd2seg.v : 분주기 + 7490 + 7447 테스트벤치 (Lab 09 Part E-1)
// 분주비를 줄여서 본다: clkdiv의 HALF = 3 → clk1 한 주기 = 6클럭(120 ns).
//   7490은 clk1의 하강 에지마다 1 증가하므로, CLOCK_50 상승 에지 6k번째마다 값이 1씩 늘어난다.
//   그래서 6k + 3번째 에지 뒤(값이 바뀌는 순간에서 먼 곳)에 Q와 HEX0을 본다.
// 기대값: Q = (s0 + k) mod 10 (정수 산술), HEX0 = 7447 글꼴 상수표 (Lab 05 4.5절 표)
//   s0는 시각 5 ns의 Q이다. 리셋 단자가 없는 회로라서 시뮬레이션의 시작값이 0이 아닐 수 있다.
//   레지스터의 전원 투입 값은 0이지만, 시각 0에 선(wire)의 값이 x에서 0으로 정해지는 것도 시뮬레이터는
//   하강 에지로 보아 7490이 미리 몇 번 셀 수 있기 때문이다(문서 Part E 참고). 실제 보드와는 상관없다.
//   +define+SCH : 회로도 netlist(bcd2seg_sch)를 검사. 이때는 Quartus에서 clkdiv의 HALF를 3으로 바꾸어
//                 컴파일한 netlist를 써야 한다(문서 Part E 참고). 다른 값이면 +define+HALF_SCH=… 로 맞춘다.
`timescale 1ns/1ps
`ifndef HALF_SCH
`define HALF_SCH 3
`endif
module tb_bcd2seg;
    localparam HALF = `HALF_SCH;
    reg  CLOCK_50;
    wire [6:0] HEX0;
    wire [3:0] Q;
    reg  [69:0] font = {7'b0011000, 7'b0000000, 7'b1111000, 7'b0000011, 7'b0010010,    // 9 8 7 6 5
                        7'b0011001, 7'b0110000, 7'b0100100, 7'b1111001, 7'b1000000};   // 4 3 2 1 0
    integer k, n, s0, errors, checks;

`ifdef SCH
    bcd2seg_sch dut (.CLOCK_50(CLOCK_50), .HEX0(HEX0), .Q(Q));
`else
    bcd2seg #(.HALF(HALF)) dut (.CLOCK_50(CLOCK_50), .HEX0(HEX0), .Q(Q));
`endif

    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        errors = 0; checks = 0; n = 0;
        CLOCK_50 = 0;
        #5 s0 = Q;
        $display(" start (5 ns) : Q = %b, HEX0 = %b  -> s0 = %0d", Q, HEX0, s0);
        checks = checks + 1;
        if (^Q === 1'bx || s0 > 9) begin errors = errors + 1; $display("   ** start value is not a BCD digit"); end
        $display("  k | QD QC QB QA | HEX0 (gfedcba) | expected");
        for (k = 0; k <= 24; k = k + 1) begin
            while (n < 2 * HALF * k + HALF) begin @(posedge CLOCK_50); n = n + 1; end
            #5;
            checks = checks + 2;
            if (Q !== (s0 + k) % 10)                  begin errors = errors + 1; $display("   ** Q    k=%0d got %0d", k, Q); end
            if (HEX0 !== font[7*((s0 + k) % 10) +: 7]) begin errors = errors + 1; $display("   ** HEX0 k=%0d got %b", k, HEX0); end
            if (k <= 11) $display(" %2d |    %b     |    %b     | %0d %b", k, Q, HEX0, (s0 + k) % 10, font[7*((s0 + k) % 10) +: 7]);
        end
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
