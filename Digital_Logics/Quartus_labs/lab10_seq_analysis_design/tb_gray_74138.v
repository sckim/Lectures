// tb_gray_74138.v : 예제 16-4 Gray 코드 카운터 테스트벤치 (Lab 10 Part D)
// 기대값은 2진수 n을 Gray 코드로 바꾸는 식 g = n xor (n >> 1)로 계산한다(2장). 회로의 J, K 식은 쓰지 않는다.
// 순서
//   1) ClrN = 0 : Q = 000
//   2) 클럭 16번(두 바퀴) : 0 1 3 2 6 7 5 4 0 1 3 2 6 7 5 4  (NOT 방식과 NAND 방식 모두)
//   3) 5번째 클럭 뒤 ClrN = 0 -> 000에서 다시 시작
//   4) (관찰) 선택 입력 비트 순서를 거꾸로 연결한 회로: 비교하지 않고 출력만 보여 준다
//   +define+SCH : NOT 방식은 회로도 netlist(gray_74138_sch)를 검사
`timescale 1ns/1ps
module tb_gray_74138;
    reg  CLK = 0, ClrN = 1;
    wire [2:0] Q, Qn, Qs;
`ifdef SCH
    gray_74138_sch   dut (.CLK(CLK), .ClrN(ClrN), .Q(Q));
`else
    gray_74138       dut (.CLK(CLK), .ClrN(ClrN), .Q(Q));
`endif
    gray_74138_nand  u_n (.CLK(CLK), .ClrN(ClrN), .Q(Qn));
    gray_74138_swap  u_s (.CLK(CLK), .ClrN(ClrN), .Q(Qs));

    integer n, i, errors, checks;
    reg [2:0] g;

    task tick; begin #5 CLK = 1; #5 CLK = 0; end endtask
    task check(input [8*8-1:0] tag);
        begin
            g = n[2:0] ^ (n[2:0] >> 1);
            checks = checks + 1;
            if (Q !== g || Qn !== g) begin
                errors = errors + 1;
                $display("   ** mismatch (%0s): Q=%b Q(nand)=%b expected %b", tag, Q, Qn, g);
            end
        end
    endtask

    initial begin
        errors = 0; checks = 0;
        #5;
        $display(" start  : Q = %b (unknown)", Q);
        ClrN = 0; #5; n = 0; check("clear"); ClrN = 1; #5;
        $display(" clock | Q (NOT) Q (NAND) | decimal | expected");
        $display("   0   |   %b     %b     |    %0d    |  %b", Q, Qn, Q, g);
        for (i = 1; i <= 16; i = i + 1) begin
            tick; n = i; check("count");
            $display("  %2d   |   %b     %b     |    %0d    |  %b", i, Q, Qn, Q, g);
        end
        for (i = 1; i <= 5; i = i + 1) begin tick; n = i; check("count"); end
        ClrN = 0; #3; n = 0; check("clear 2"); ClrN = 1; #2;
        tick; n = 1; check("restart");
        $display(" ClrN in the middle : back to 000, then %b", Q);
        // 잘못 연결한 회로(관찰만)
        ClrN = 0; #5; ClrN = 1; #5;
        $write(" swapped select bits (Q[2] -> A) : %b", Qs);
        for (i = 1; i <= 6; i = i + 1) begin tick; $write(" -> %b", Qs); end
        $display("");
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
