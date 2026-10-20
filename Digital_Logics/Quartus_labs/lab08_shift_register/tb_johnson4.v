// tb_johnson4.v : 4비트 존슨 카운터와 수정 식 테스트벤치 (Lab 08 Part D-2, Verilog만)
// 기대값은 상태표를 16진 상수로 적은 것이다(18.3절 표와 18.3.4절 [정리자 주]의 식을 손으로 푼 결과).
//   nxt_orig[q] : DA = QD', DB = QA, DC = QB,            DD = QC
//   nxt_fix[q]  : DA = QD', DB = QA, DC = (QA + QC)·QB, DD = QC
//   (상수의 맨 오른쪽 한 자리가 q = 0의 다음 상태, 맨 왼쪽이 q = 15의 다음 상태)
// 1) johnson4, johnson4_fix : 리셋 뒤 정상 8상태 고리
// 2) 16가지 시작 상태를 하나씩 직접 넣고(dut.q = …) 8 에지 동안 상태표와 비교,
//    수정 식은 몇 클럭 만에 정상 고리로 들어오는지 출력
// 3) johnson4_top : RSTN, LDN(시작값 로드), FIX 선택이 위 표대로 동작하는지
`timescale 1ns/1ps
module tb_johnson4;
    reg clk, rst;
    wire [3:0] qo, qf;
    reg  [63:0] nxt_orig = 64'h7f6e5d4c3b2a1908;
    reg  [63:0] nxt_fix  = 64'h7f6e5d4c3b081908;
    reg  [15:0] normal   = 16'b1101_0001_1000_1011;   // 정상 고리 0,1,3,7,8,12,14,15 → 비트 위치에 1
    reg  [3:0]  eo, ef;
    integer s, i, n, errors, checks;

    johnson4     u_o (.clk(clk), .rst(rst), .q(qo));
    johnson4_fix u_f (.clk(clk), .rst(rst), .q(qf));

    // johnson4_top
    reg CLK, RSTN, LDN, FIX; reg [3:0] D; wire [3:0] Q; reg [3:0] et;
    johnson4_top u_t (.CLK(CLK), .RSTN(RSTN), .LDN(LDN), .FIX(FIX), .D(D), .Q(Q));

    task cmp (input [3:0] got, input [3:0] exp, input [8*10-1:0] tag);
        begin
            checks = checks + 1;
            if (got !== exp) begin errors = errors + 1; $display("   ** mismatch (%0s): got %b expected %b", tag, got, exp); end
        end
    endtask

    task tick;      // 공통 클럭 한 번 (상승 에지)
        begin #10 clk = 1; #10 clk = 0; end
    endtask

    task tick_top;  // KEY0처럼: 누름(0) → 뗌(1)이 상승 에지
        begin #10 CLK = 0; #10 CLK = 1; #10; end
    endtask

    initial begin
        errors = 0; checks = 0;
        clk = 0; rst = 1; tick; rst = 0;
        // 1) 정상 고리
        eo = 4'b0000; ef = 4'b0000;
        $display(" clk | johnson4 | johnson4_fix");
        for (i = 1; i <= 9; i = i + 1) begin
            tick; eo = nxt_orig[4*eo +: 4]; ef = nxt_fix[4*ef +: 4];
            cmp(qo, eo, "orig loop"); cmp(qf, ef, "fix loop");
            $display("  %0d  |   %b   |   %b", i, qo, qf);
        end
        // 2) 16가지 시작 상태
        $display(" start | johnson4, 8 clocks later | johnson4_fix: clocks to normal loop");
        for (s = 0; s < 16; s = s + 1) begin
            #5 u_o.q = s; u_f.q = s; eo = s; ef = s; n = -1; #5;
            if (normal[s]) n = 0;
            for (i = 1; i <= 8; i = i + 1) begin
                tick; eo = nxt_orig[4*eo +: 4]; ef = nxt_fix[4*ef +: 4];
                cmp(qo, eo, "orig"); cmp(qf, ef, "fix");
                if (n < 0 && normal[qf]) n = i;
            end
            if (normal[s]) $display("  %b | ends in %s loop | 0 (already normal)", s[3:0], normal[qo] ? "normal  " : "abnormal");
            else           $display("  %b | ends in %s loop | %0d", s[3:0], normal[qo] ? "normal  " : "abnormal", n);
            cmp(normal[qo], normal[s], "orig stays");       // 원래 회로는 처음 고리를 벗어나지 못한다
            cmp(normal[qf], 1'b1, "fix recov");             // 수정 회로는 8클럭 안에 정상 고리
        end
        // 3) johnson4_top
        CLK = 1; RSTN = 1; LDN = 1; FIX = 0; D = 4'b0000;
        #10 RSTN = 0; #10; cmp(Q, 4'b0000, "top rst"); RSTN = 1; #10;
        et = 4'b0000;
        for (i = 0; i < 8; i = i + 1) begin tick_top; et = nxt_orig[4*et +: 4]; cmp(Q, et, "top loop"); end
        D = 4'b1010; LDN = 0; #10; tick_top; LDN = 1; #10; et = 4'b1010; cmp(Q, et, "top load");
        for (i = 0; i < 4; i = i + 1) begin tick_top; et = nxt_orig[4*et +: 4]; cmp(Q, et, "top FIX=0"); end
        $display(" top: load 1010, FIX=0, 4 clocks -> %b (abnormal loop)", Q);
        FIX = 1; #10;
        for (i = 0; i < 6; i = i + 1) begin tick_top; et = nxt_fix[4*et +: 4]; cmp(Q, et, "top FIX=1"); end
        $display(" top: FIX=1, 6 clocks -> %b (normal loop)", Q);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
