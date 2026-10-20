// tb_siso.v : 4비트 SISO/SIPO 시프트 레지스터 테스트벤치 (Lab 08 Part A)
// 기대값은 DUT와 따로 정한다.
//   - 예제 12-1, 12-2, 12-3 : 교재 표의 답(QA QB QC QD)을 상수로 적어 비교
//   - 마지막 무작위 구간     : 정수 산술 모델  e = Shift ? (e >> 1) + 8*SI : e
// 클럭은 보드와 같게 준다. Clock = KEY0 (누르면 0, 떼면 1). 떼는 순간(0 → 1)이 상승 에지이다.
// 입력은 Clock = 1(뗀 상태)일 때 바꾸고, 에지와 같은 시각에 바꾸지 않는다.
//   +define+SCH : 회로도 netlist(siso_reg_sch)를 검사
`timescale 1ns/1ps
module tb_siso;
    reg  SI, Shift, Clock, ClrN;
    wire Q3, Q2, Q1, Q0;
    wire [3:0] Q = {Q3, Q2, Q1, Q0};          // QA QB QC QD
    reg  [3:0] e;
    integer i, errors, checks;
    reg [31:0] lfsr;

`ifdef SCH
    siso_reg_sch dut (.SI(SI), .Shift(Shift), .Clock(Clock), .ClrN(ClrN), .Q3(Q3), .Q2(Q2), .Q1(Q1), .Q0(Q0));
`else
    siso_reg     dut (.SI(SI), .Shift(Shift), .Clock(Clock), .ClrN(ClrN), .Q3(Q3), .Q2(Q2), .Q1(Q1), .Q0(Q0));
`endif

    task compare (input [3:0] exp, input [8*16-1:0] tag);
        begin
            checks = checks + 1;
            if (Q !== exp) begin
                errors = errors + 1;
                $display("   ** mismatch (%0s): got %b expected %b", tag, Q, exp);
            end
        end
    endtask

    task clock_once;            // KEY0을 눌렀다 뗀다
        begin
            #10 Clock = 0;      // 누름
            #10 Clock = 1;      // 뗌 = 상승 에지
            #10;
        end
    endtask

    task clear_reg;             // KEY1을 눌렀다 뗀다 (클럭 없이)
        begin
            ClrN = 0; #10; compare(4'b0000, "clear"); ClrN = 1; #10;
        end
    endtask

    // 예제 표 (위 → 아래가 에지 1 → 6). 상수 비트열은 왼쪽이 에지 1
    reg [5:0]  ex1_si  = 6'b1_0_1_1_0_0;
    reg [23:0] ex1_q   = 24'b1000_0100_1010_1101_0110_0011;     // 예제 12-1 (+0, 0 두 번)
    reg [5:0]  ex2_sh  = 6'b1_1_0_0_1_1;
    reg [5:0]  ex2_si  = 6'b1_1_0_1_0_1;
    reg [23:0] ex2_q   = 24'b1010_1101_1101_1101_0110_1011;     // 예제 12-2
    reg [5:0]  ex3_si  = 6'b0_1_1_0_0_0;
    reg [23:0] ex3_q   = 24'b0111_1011_1101_0110_0011_0001;     // 예제 12-3

    initial begin
        errors = 0; checks = 0; lfsr = 32'h1357_9BDF;
        SI = 0; Shift = 0; Clock = 1; ClrN = 1;
        #10 $display(" start : QA QB QC QD = %b (unknown)", Q);
        clear_reg;
        $display(" clear : QA QB QC QD = %b", Q);

        // 예제 12-1 : 0000에서 1, 0, 1, 1 (그리고 0, 0)
        $display(" [ex 12-1] edge | Shift SI | QA QB QC QD | expected");
        Shift = 1;
        for (i = 0; i < 6; i = i + 1) begin
            SI = ex1_si[5 - i]; clock_once;
            $display("            %0d  |   %b   %b |    %b     |   %b", i + 1, Shift, SI, Q, ex1_q[23 - 4*i -: 4]);
            compare(ex1_q[23 - 4*i -: 4], "ex 12-1");
        end

        // 예제 12-2 : 처음 0101로 만든 뒤(1, 0, 1, 0을 넣음) 시프트 인에이블
        clear_reg; Shift = 1;
        SI = 1; clock_once; SI = 0; clock_once; SI = 1; clock_once; SI = 0; clock_once;
        compare(4'b0101, "preset 0101");
        $display(" [ex 12-2] start %b", Q);
        for (i = 0; i < 6; i = i + 1) begin
            Shift = ex2_sh[5 - i]; SI = ex2_si[5 - i]; clock_once;
            $display("            %0d  |   %b   %b |    %b     |   %b", i + 1, Shift, SI, Q, ex2_q[23 - 4*i -: 4]);
            compare(ex2_q[23 - 4*i -: 4], "ex 12-2");
        end

        // 예제 12-3 : 처음 1111(1을 네 번 넣음), 입력 0, 1, 1, 0, 0, 0
        Shift = 1; SI = 1; repeat (4) clock_once;
        compare(4'b1111, "preset 1111");
        $display(" [ex 12-3] start %b", Q);
        for (i = 0; i < 6; i = i + 1) begin
            SI = ex3_si[5 - i]; clock_once;
            $display("            %0d  |   %b   %b |    %b     |   %b", i + 1, Shift, SI, Q, ex3_q[23 - 4*i -: 4]);
            compare(ex3_q[23 - 4*i -: 4], "ex 12-3");
        end

        // 비동기 클리어: 클럭 없이 즉시 0000
        ClrN = 0; #5; compare(4'b0000, "async clear"); #5; ClrN = 1; #10;
        $display(" ClrN=0 (no clock) : %b", Q);

        // 무작위 32 에지: 정수 산술 모델
        e = 4'b0000;
        for (i = 0; i < 32; i = i + 1) begin
            lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
            SI = lfsr[0]; Shift = lfsr[3] | lfsr[5];
            clock_once;
            if (Shift) e = (e >> 1) + 8 * SI;
            compare(e, "random");
        end
        $display(" random 32 edges : done");
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
