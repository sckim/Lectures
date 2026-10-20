// tb_design15.v : 예제 15-2 상태도를 JK·D·T로 설계한 세 회로 테스트벤치 (Lab 10 Part C)
// 기대값은 15.4절 상태표를 상수 배열로 옮겨 계산한다. 세 회로가 매 클럭 상태표와 같아야 한다.
// 순서
//   1) ClrN = 0 : 모두 00
//   2) 15.4절 "검증" 표의 입력 x = 1 1 0 0 1 1 1 0
//   3) 의사 난수 x로 클럭 64번, (상태, x) 8가지가 모두 나왔는지 검사
//   +define+SCH : JK·D는 회로도 netlist(design15_jk_d_sch)를 검사한다. T는 언제나 Verilog(ex15_t)이다
`timescale 1ns/1ps
module tb_design15;
    reg  CLK = 0, ClrN = 1, X = 0;
    wire A_JK, B_JK, A_D, B_D, A_T, B_T;
`ifdef SCH
    design15_jk_d_sch dut (.CLK(CLK), .ClrN(ClrN), .X(X), .A_JK(A_JK), .B_JK(B_JK), .A_D(A_D), .B_D(B_D));
`else
    design15_jk_d     dut (.CLK(CLK), .ClrN(ClrN), .X(X), .A_JK(A_JK), .B_JK(B_JK), .A_D(A_D), .B_D(B_D));
`endif
    ex15_t u_t (.CLK(CLK), .ClrN(ClrN), .X(X), .A(A_T), .B(B_T));

    // 상태표 (15.4절)  현재 AB | 다음 x=0 | 다음 x=1
    //                   00     |   00     |   01
    //                   01     |   10     |   01
    //                   10     |   10     |   11
    //                   11     |   11     |   00
    reg [1:0] NEXT [0:7];
    reg [1:0] s;
    reg [7:0] seen;
    reg [31:0] lfsr;
    integer i, errors, checks;
    reg [7:0] v = 8'b1_1_0_0_1_1_1_0;   // 15.4절 검증 표의 x (클럭 1이 맨 왼쪽)

    task check(input [8*10-1:0] tag);
        begin
            checks = checks + 1;
            if ({A_JK, B_JK} !== s || {A_D, B_D} !== s || {A_T, B_T} !== s) begin
                errors = errors + 1;
                $display("   ** mismatch (%0s): JK %b%b D %b%b T %b%b expected %b", tag, A_JK, B_JK, A_D, B_D, A_T, B_T, s);
            end
        end
    endtask

    task step(input xv);
        reg [1:0] cur;
        begin
            X = xv; #5;
            cur = s; seen[{cur, xv}] = 1'b1;
            CLK = 1; #1; s = NEXT[{cur, xv}]; #4;
            CLK = 0; #5;
            check("edge");
        end
    endtask

    initial begin
        NEXT[0] = 2'b00; NEXT[1] = 2'b01;
        NEXT[2] = 2'b10; NEXT[3] = 2'b01;
        NEXT[4] = 2'b10; NEXT[5] = 2'b11;
        NEXT[6] = 2'b11; NEXT[7] = 2'b00;
        errors = 0; checks = 0; seen = 0; lfsr = 32'h0F1E_2D3C;
        #5;
        ClrN = 0; #5; s = 2'b00; check("clear"); ClrN = 1; #5;
        $display(" clock | AB | x | JK  D   T  | expected");
        for (i = 7; i >= 0; i = i - 1) begin : ver
            reg [1:0] before;
            before = s;
            step(v[i]);
            $display("   %0d   | %b | %b | %b%b  %b%b  %b%b |   %b", 8 - i, before, v[i], A_JK, B_JK, A_D, B_D, A_T, B_T, s);
        end
        for (i = 0; i < 64; i = i + 1) begin
            lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
            step(lfsr[0]);
        end
        checks = checks + 1;
        if (seen !== 8'hFF) begin errors = errors + 1; $display("   ** not all (state, x) pairs visited: %b", seen); end
        $display(" random 64 clocks : done, (state, x) pairs visited = %b", seen);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
