// tb_bcd.v : 동기식 BCD 카운터와 HEX0 표시 테스트벤치 (Lab 09 Part E-2, Verilog만)
// 1) bcd_hex : 클리어 뒤 25 에지. 기대값 q = k mod 10, C = (q == 9), HEX0 = 16진 글꼴 상수표
// 2) 미사용 상태 : bcd_counter의 q에 10–15를 직접 넣고(u_cnt.q = …) 다음 상태와 c를 상수표와 비교
//      다음 상태  10→11, 11→12, 12→13, 13→14, 14→15, 15→0   (q == 9가 아니면 q + 1, 4비트라 15 + 1 = 0)
//      c = Q3·Q0 : 11, 13, 15에서도 1이 된다(9만 검출한다고 보면 틀린다)
// 클럭은 KEY0처럼 준다(떼는 순간 상승 에지).
`timescale 1ns/1ps
module tb_bcd;
    reg  CLK, CLRN;
    wire [6:0] HEX0;
    wire [3:0] LEDR;
    wire C;
    reg  [111:0] font = {7'b0001110, 7'b0000110, 7'b0100001, 7'b1000110, 7'b0000011, 7'b0001000,  // F E d C b A
                         7'b0010000, 7'b0000000, 7'b1111000, 7'b0000010, 7'b0010010,              // 9 8 7 6 5
                         7'b0011001, 7'b0110000, 7'b0100100, 7'b1111001, 7'b1000000};             // 4 3 2 1 0
    // 다음 상태표: 0→1, …, 8→9, 9→0, 10→11, …, 14→15, 15→0  (맨 오른쪽 자리가 상태 0의 다음)
    reg  [63:0] nxt   = 64'h0FEDCB0987654321;
    reg  [15:0] c_tab = 16'b1010_1010_0000_0000;   // c = 1인 상태: 9, 11, 13, 15 (비트 위치)
    integer k, s, errors, checks;
    reg [3:0] e;

    bcd_hex dut (.CLK(CLK), .CLRN(CLRN), .HEX0(HEX0), .LEDR(LEDR), .C(C));

    task clock_once;
        begin #10 CLK = 0; #10 CLK = 1; #10; end
    endtask

    initial begin
        errors = 0; checks = 0;
        CLK = 1; CLRN = 1;
        #10 CLRN = 0; #10; CLRN = 1; #10;
        $display(" edge | q (dec) C | HEX0");
        e = 0;
        for (k = 1; k <= 25; k = k + 1) begin
            clock_once; e = nxt[4*e +: 4];
            checks = checks + 3;
            if (LEDR !== k % 10)          begin errors = errors + 1; $display("   ** q k=%0d", k); end
            if (C !== c_tab[e])            begin errors = errors + 1; $display("   ** C k=%0d", k); end
            if (HEX0 !== font[7*e +: 7])   begin errors = errors + 1; $display("   ** HEX0 k=%0d", k); end
            if (k <= 11) $display("  %2d  | %b (%0d) %b | %b", k, LEDR, LEDR, C, HEX0);
        end
        $display(" unused start | next states            | C at each state");
        for (s = 10; s <= 15; s = s + 1) begin
            #5 dut.u_cnt.q = s; e = s; #5;
            $write("      %2d      |", s);
            for (k = 0; k < 6; k = k + 1) begin
                checks = checks + 2;
                if (C !== c_tab[e])          begin errors = errors + 1; $display("   ** C s=%0d", e); end
                if (HEX0 !== font[7*e +: 7]) begin errors = errors + 1; $display("   ** HEX0 s=%0d", e); end
                $write(" %0d(c%b)", LEDR, C);
                clock_once; e = nxt[4*e +: 4];
                checks = checks + 1;
                if (LEDR !== e) begin errors = errors + 1; $display("   ** next s=%0d", s); end
            end
            $display(" -> %0d", LEDR);
        end
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
