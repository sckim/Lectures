// tb_gray.v : 3비트 Gray 코드 카운터 테스트벤치 (Lab 09 Part F)
// 기대값은 Gray 순서를 상수로 적은 것이다: 000 → 001 → 011 → 010 → 110 → 111 → 101 → 100 → 000
// 1) gray3_jk(회로도와 같은 구조) : 전원 투입 값 000에서 16 에지 (두 바퀴). 매 에지에서 한 비트만 바뀌는지도 센다
// 2) gray3(18.10절, case 문)      : 리셋 뒤 16 에지, 같은 상수표
// 클럭은 0에서 시작해 0 → 1(상승 에지) → 0으로 준다. 보드의 KEY0(떼는 순간 상승 에지)과 순서만 다르다.
//   이 회로는 클리어가 없어서, KEY0처럼 1에서 시작하면 시각 0에 클럭 선이 x → 1로 바뀌는 것을
//   시뮬레이터가 상승 에지로 보고 x를 저장해 버린다(문서 Part F 참고).
//   +define+SCH : 1)을 회로도 netlist(gray3_sch)로 검사
`timescale 1ns/1ps
module tb_gray;
    reg  CLK = 1'b0, rst = 1'b0;
    wire [2:0] Q, g;
    reg  [23:0] seq = {3'b100, 3'b101, 3'b111, 3'b110, 3'b010, 3'b011, 3'b001, 3'b000};  // [0] = 000
    reg  [2:0] prev;
    integer k, errors, checks, onebit;

`ifdef SCH
    gray3_sch dut (.CLK(CLK), .Q(Q));
`else
    gray3_jk  dut (.CLK(CLK), .Q(Q));
`endif
    gray3 ref_case (.clk(CLK), .rst(rst), .g(g));

    task clock_once;
        begin #10 CLK = 1; #10 CLK = 0; #10; end
    endtask

    initial begin
        errors = 0; checks = 0; onebit = 0;
        #5;
        checks = checks + 1; if (Q !== 3'b000) errors = errors + 1;
        $display(" power-up : Q = %b", Q);
        $display(" edge | gray3_jk Q (dec) | expected | gray3 (case) | expected");
        rst = 1; clock_once; rst = 0;                       // 에지 1: gray3(case 문)만 리셋한다. gray3_jk는 000 → 001
        checks = checks + 2;
        if (Q !== 3'b001) errors = errors + 1;
        if (g !== 3'b000) errors = errors + 1;
        $display("   1  |    %b (%0d)       |   001    |  %b (reset)  |   000", Q, Q, g);
        for (k = 2; k <= 17; k = k + 1) begin
            prev = Q;
            clock_once;
            checks = checks + 2;
            if (Q !== seq[3*(k % 8) +: 3])       begin errors = errors + 1; $display("   ** jk   k=%0d got %b", k, Q); end
            if (g !== seq[3*((k - 1) % 8) +: 3]) begin errors = errors + 1; $display("   ** case k=%0d got %b", k, g); end
            if ((Q ^ prev) == 3'b001 || (Q ^ prev) == 3'b010 || (Q ^ prev) == 3'b100) onebit = onebit + 1;
            if (k <= 9) $display("  %2d  |    %b (%0d)       |   %b    |  %b         |   %b", k, Q, Q, seq[3*(k % 8) +: 3], g, seq[3*((k - 1) % 8) +: 3]);
        end
        checks = checks + 1; if (onebit != 16) errors = errors + 1;
        $display(" one-bit changes : %0d of 16 edges", onebit);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
