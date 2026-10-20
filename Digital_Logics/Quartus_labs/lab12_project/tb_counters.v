// tb_counters.v : BCD 카운터 테스트벤치 (Lab 12 Part A, 22.7.1절)
//   bcd_cnt(MAX = 9, 5), cnt60, cnt24를 한꺼번에 검사한다.
//   기대값은 정수 하나(v)로 따로 계산한다:  en = 1이면 v = (v + 1) mod M
//   표시는 tens = v / 10, ones = v % 10,  자리올림 co = en && v == M - 1
//   en은 처음 150클럭은 늘 1(경계 59→00, 23→00을 두 번 이상 지남), 그 뒤 150클럭은 의사 난수.
`timescale 1ns/1ps
module tb_counters;
    reg clk = 0, rst_n = 0, en = 0;
    always #10 clk = ~clk;
    wire [3:0] q10, q6, t60, o60, t24, o24;
    wire c10, c6, co60;
    bcd_cnt #(.MAX(4'd9)) u10 (.clk(clk), .rst_n(rst_n), .en(en), .q(q10), .co(c10));
    bcd_cnt #(.MAX(4'd5)) u6  (.clk(clk), .rst_n(rst_n), .en(en), .q(q6),  .co(c6));
    cnt60 u60 (.clk(clk), .rst_n(rst_n), .en(en), .tens(t60), .ones(o60), .co(co60));
    cnt24 u24 (.clk(clk), .rst_n(rst_n), .en(en), .tens(t24), .ones(o24));

    integer v10 = 0, v6 = 0, v60 = 0, v24 = 0;    // 기대값(정수)
    integer k, errors = 0, checks = 0, wraps60 = 0, wraps24 = 0;
    reg [15:0] lfsr = 16'hACE1;
    reg co_seen;                                   // 상승 에지 직전에 본 cnt60의 co

    task check (input integer got, input integer exp, input [8*8-1:0] tag);
        begin
            checks = checks + 1;
            if (got !== exp) begin
                errors = errors + 1;
                $display("   ** mismatch %0s at k=%0d: got %0d expected %0d", tag, k, got, exp);
            end
        end
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1;
        $display(" k  en | cnt60 co | exp  | cnt24 | exp   (co = value just before the edge)");
        for (k = 1; k <= 300; k = k + 1) begin
            // 하강 에지에서 en을 정하고, 자리올림(조합 출력)을 먼저 확인한다
            if (k <= 150) en = 1;
            else begin lfsr = {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]}; en = lfsr[0]; end
            #1;
            check(c10,  en && v10 == 9,  "co10");
            check(c6,   en && v6  == 5,  "co6");
            check(co60, en && v60 == 59, "co60");
            co_seen = co60;
            @(posedge clk); #1;            // 상승 에지에서 증가
            if (en) begin
                if (v60 == 59) wraps60 = wraps60 + 1;
                if (v24 == 23) wraps24 = wraps24 + 1;
                v10 = (v10 + 1) % 10; v6 = (v6 + 1) % 6;
                v60 = (v60 + 1) % 60; v24 = (v24 + 1) % 24;
            end
            check(q10, v10, "mod10");
            check(q6,  v6,  "mod6");
            check(t60, v60 / 10, "tens60"); check(o60, v60 % 10, "ones60");
            check(t24, v24 / 10, "tens24"); check(o24, v24 % 10, "ones24");
            if ((k >= 57 && k <= 61) || (k >= 22 && k <= 25) || (k >= 117 && k <= 121))
                $display("%3d  %b  |  %0d%0d   %b  |  %02d  |  %0d%0d   | %02d",
                         k, en, t60, o60, co_seen, v60, t24, o24, v24);
            @(negedge clk);
        end
        $display(" wraps: cnt60 59->00 %0d times, cnt24 23->00 %0d times", wraps60, wraps24);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
