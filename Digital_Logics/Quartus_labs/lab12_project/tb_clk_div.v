// tb_clk_div.v : 분주기 테스트벤치 (Lab 12 Part A, 22.7.1절 "clk_div (N = 4)")
//   기대값: 리셋을 푼 뒤 k번째 상승 에지가 지나면 tick = 1  ⇔  k가 N의 배수 (k >= 1)
//   (카운터가 0..N-1을 세고, N-1에서 다음 에지에 tick을 1로 만든다)
//   N = 4와 N = 5 두 가지로 각각 40클럭을 확인하고, tick이 정확히 1클럭 폭인지도 본다.
`timescale 1ns/1ps
module tb_clk_div;
    reg clk = 0, rst_n = 0;
    always #10 clk = ~clk;                 // 50 MHz (주기 20 ns)
    wire tick4, tick5;
    clk_div #(.N(4)) u4 (.clk(clk), .rst_n(rst_n), .tick(tick4));
    clk_div #(.N(5)) u5 (.clk(clk), .rst_n(rst_n), .tick(tick5));
    integer k, errors = 0, checks = 0, n4 = 0, n5 = 0;
    reg e4, e5;
    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1;                          // 하강 에지에서 리셋 해제 (상승 에지와 겹치지 않게)
        $display(" edge | tick(N=4) exp | tick(N=5) exp");
        for (k = 1; k <= 40; k = k + 1) begin
            @(negedge clk);                 // k번째 상승 에지가 지난 뒤의 하강 에지에서 확인
            e4 = (k % 4 == 0);
            e5 = (k % 5 == 0);
            checks = checks + 2;
            if (tick4 !== e4) errors = errors + 1;
            if (tick5 !== e5) errors = errors + 1;
            n4 = n4 + tick4; n5 = n5 + tick5;
            if (k <= 12) $display("  %2d  |     %b      %b  |     %b      %b", k, tick4, e4, tick5, e5);
        end
        $display(" ... 40 edges: tick(N=4) %0d times, tick(N=5) %0d times", n4, n5);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
