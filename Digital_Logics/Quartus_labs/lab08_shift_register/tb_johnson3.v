// tb_johnson3.v : 3비트 존슨 카운터 테스트벤치 (Lab 08 Part D-1)
// 기대값은 예제 12-12의 상태표를 상수로 적은 것이다(DUT 코드를 쓰지 않는다).
//   현재 Q2 Q1 Q0 : 000 001 010 011 100 101 110 111
//   다음 Q2 Q1 Q0 : 100 000 101 001 110 010 111 011
// 1) 클리어 뒤 12 에지: 000 → 100 → 110 → 111 → 011 → 001 → 000 … (6상태 고리 두 바퀴)
// 2) (Verilog만) 미사용 상태 010, 101을 직접 넣고 2상태 고리에 갇히는 것을 본다
// 클럭은 KEY0처럼 준다(떼는 순간 상승 에지).
//   +define+SCH : 회로도 netlist(johnson3_sch)를 검사 (2는 건너뜀)
`timescale 1ns/1ps
module tb_johnson3;
    reg  Clk, ClrN;
    wire Q2, Q1, Q0;
    wire [2:0] Q = {Q2, Q1, Q0};
    reg  [2:0] e;
    reg  [23:0] next_tab = {3'b011, 3'b111, 3'b010, 3'b110, 3'b001, 3'b101, 3'b000, 3'b100};  // [7] … [0]
    integer i, errors, checks;

`ifdef SCH
    johnson3_sch dut (.Clk(Clk), .ClrN(ClrN), .Q2(Q2), .Q1(Q1), .Q0(Q0));
`else
    johnson3     dut (.Clk(Clk), .ClrN(ClrN), .Q2(Q2), .Q1(Q1), .Q0(Q0));
`endif

    task compare (input [8*10-1:0] tag);
        begin
            checks = checks + 1;
            if (Q !== e) begin
                errors = errors + 1;
                $display("   ** mismatch (%0s): got %b expected %b", tag, Q, e);
            end
        end
    endtask

    task clock_once;
        begin
            #10 Clk = 0;
            #10 Clk = 1;
            #10;
            e = next_tab[3*e +: 3];
        end
    endtask

    initial begin
        errors = 0; checks = 0;
        Clk = 1; ClrN = 1;
        #10 $display(" start : Q2 Q1 Q0 = %b (unknown)", Q);
        ClrN = 0; #10; e = 3'b000; compare("clear"); ClrN = 1; #10;
        $display(" edge | Q2 Q1 Q0 | expected");
        $display("   0  |   %b    |   %b", Q, e);
        for (i = 1; i <= 12; i = i + 1) begin
            clock_once; compare("main loop");
            $display("  %2d  |   %b    |   %b", i, Q, e);
        end
`ifndef SCH
        // 미사용 상태에서 시작 (전원 직후 우연히 이 값이었다고 가정)
        dut.q = 3'b010; e = 3'b010; #10;
        $display(" force 010 :");
        for (i = 1; i <= 4; i = i + 1) begin
            clock_once; compare("unused");
            $display("  %2d  |   %b    |   %b", i, Q, e);
        end
        ClrN = 0; #10; e = 3'b000; compare("recover"); ClrN = 1; #10;
        $display(" ClrN=0 -> %b : back to the main loop only by clearing", Q);
`endif
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
