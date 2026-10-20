// tb_div.v : 분주기 테스트벤치 (Lab 09 Part A)
// 시뮬레이션에서 5천만 클럭을 돌릴 수 없으므로 인스턴스 파라미터로 줄인다: HALF = 3, N = 6
// 기대값은 리셋을 푼 뒤 들어온 상승 에지 수 k로 따로 계산한다(정수 산술).
//   clkdiv 출력 LEDR[0] = (k / HALF) mod 2           (HALF번째 에지마다 뒤집힘)
//   clk_div tick       = 1  (k ≥ N이고 k mod N = 0인 에지 바로 뒤 한 클럭)
//   카운터 LEDR[4:1]   = ((k − 1) / N) mod 16        (tick이 1인 다음 에지에서 1 증가)
`timescale 1ns/1ps
module tb_div;
    localparam HALF = 3, N = 6;
    reg  CLOCK_50, rst_n;
    wire [4:0] LEDR;
    integer k, errors, checks, ticks, toggles;
    reg  e_sq, prev_sq; reg [3:0] e_cnt; reg e_tick;

    div_top #(.HALF(HALF), .N(N)) dut (.CLOCK_50(CLOCK_50), .rst_n(rst_n), .LEDR(LEDR));

    always #10 CLOCK_50 = ~CLOCK_50;          // 20 ns = 50 MHz

    initial begin
        errors = 0; checks = 0; ticks = 0; toggles = 0;
        CLOCK_50 = 0; rst_n = 0;
        #35 rst_n = 1;                        // 상승 에지(10, 30, 50 …)와 떨어진 시각에 푼다
        $display("  k | LEDR0(sq) tick | LEDR[4:1] | expected sq tick cnt");
        prev_sq = 0;
        for (k = 1; k <= 120; k = k + 1) begin
            @(posedge CLOCK_50); #5;          // 에지 5 ns 뒤에 본다
            e_sq   = (k / HALF) % 2;
            e_tick = (k >= N) && (k % N == 0);
            e_cnt  = ((k - 1) / N) % 16;
            checks = checks + 3;
            if (LEDR[0] !== e_sq)          begin errors = errors + 1; $display("  ** sq   k=%0d", k); end
            if (dut.tick !== e_tick)       begin errors = errors + 1; $display("  ** tick k=%0d", k); end
            if (LEDR[4:1] !== e_cnt)       begin errors = errors + 1; $display("  ** cnt  k=%0d", k); end
            if (dut.tick) ticks = ticks + 1;
            if (LEDR[0] !== prev_sq) toggles = toggles + 1;
            prev_sq = LEDR[0];
            if (k <= 14 || k % 30 == 0)
                $display(" %3d |     %b      %b   |   %b    |    %0d     %0d    %0d", k, LEDR[0], dut.tick, LEDR[4:1], e_sq, e_tick, e_cnt);
        end
        $display(" 120 clocks: LEDR0 toggled %0d times (expected %0d), tick = 1 for %0d clocks (expected %0d)",
                 toggles, 120 / HALF, ticks, 120 / N);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
