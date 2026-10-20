// tb_traffic.v : 신호등 테스트벤치 (Lab 12 선택 과제 1, 22.5.4절 표, 연습문제 10)
//   분주비 N = 3. 두 신호등을 함께 돌린다.
//     u52 : TG = 5, TY = 2 → 한 주기 14초 (22.5.4절 표)
//     u41 : TG = 4, TY = 1 → 한 주기 10초 (22장 연습문제 10)
//   기대값은 "리셋 뒤 지난 초" s로 따로 정한다: 한 주기 안의 위치 p = s mod (2TG + 2TY)
//     p < TG : A 녹 B 적 | p < TG+TY : A 황 B 적 | p < 2TG+TY : A 적 B 녹 | 나머지 : A 적 B 황
//   지난 초 s: 리셋 해제 뒤 e번째 상승 에지에서 (e-1)이 N의 배수이고 e > 1이면 1 증가 (tb_digital_clock과 같은 규칙)
`timescale 1ns/1ps
module tb_traffic;
    localparam N = 3;
    reg clk = 0, rst_n = 0;
    always #10 clk = ~clk;
    wire [2:0] A52, B52, A41, B41;
    traffic #(.N(N), .TG(5), .TY(2)) u52 (.clk(clk), .rst_n(rst_n), .A(A52), .B(B52));
    traffic #(.N(N), .TG(4), .TY(1)) u41 (.clk(clk), .rst_n(rst_n), .A(A41), .B(B41));

    integer e = 0, s = 0, last_s = -1, errors = 0, checks = 0;
    reg run = 0;
    always @(posedge clk) if (run) begin
        e = e + 1;
        if (e > 1 && (e - 1) % N == 0) s = s + 1;
    end

    function [5:0] lights (input integer sec, input integer tg, input integer ty);   // {A, B}
        integer p;
        begin
            p = sec % (2 * tg + 2 * ty);
            if      (p < tg)               lights = {3'b001, 3'b100};
            else if (p < tg + ty)          lights = {3'b010, 3'b100};
            else if (p < 2 * tg + ty)      lights = {3'b100, 3'b001};
            else                           lights = {3'b100, 3'b010};
        end
    endfunction
    function [8*2-1:0] name (input [2:0] x);
        name = (x == 3'b001) ? "G " : (x == 3'b010) ? "Y " : (x == 3'b100) ? "R " : "??";
    endfunction

    always @(negedge clk) if (run) begin
        checks = checks + 2;
        if ({A52, B52} !== lights(s, 5, 2)) errors = errors + 1;
        if ({A41, B41} !== lights(s, 4, 1)) errors = errors + 1;
        if (s != last_s && s <= 15) begin
            $display("  %2d  |  %s %s |  %s %s", s, name(A52), name(B52), name(A41), name(B41));
            last_s = s;
        end
    end

    initial begin
        $display("  sec | TG5 TY2: A B | TG4 TY1: A B   (G green, Y yellow, R red)");
        repeat (2) @(negedge clk);
        rst_n = 1; run = 1;
        wait (s == 43);                      // 43초까지 (TG5 TY2 세 주기 = 42초, TG4 TY1 네 주기 = 40초를 넘김)
        @(negedge clk);
        $display("  ... checked up to %0d s", s);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
