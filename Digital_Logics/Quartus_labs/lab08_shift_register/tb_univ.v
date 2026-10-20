// tb_univ.v : 4비트 범용 시프트 레지스터(74194) 테스트벤치 (Lab 08 Part C)
// 기대값은 DUT와 따로 정한다.
//   - 예제 12-7 : 교재 표의 답(QA QB QC QD)을 상수로 적어 비교
//   - 무작위 구간 : 정수 산술 모델 (QA = 8의 자리, QD = 1의 자리)
//       00 유지 e = e,  01 오른쪽 e = e/2 + 8*SR,  10 왼쪽 e = (2e mod 16) + SL,  11 로드 e = In
// 클럭은 KEY0처럼 준다(떼는 순간 상승 에지). 입력은 Clk = 1일 때 바꾼다.
//   +define+SCH : 회로도 netlist(univ74194_sch)를 검사
`timescale 1ns/1ps
module tb_univ;
    reg        SLSI, SRSI, S0, S1, ClrN, Clk;
    reg  [3:0] In;
    wire       QA, QB, QC, QD;
    wire [3:0] Q = {QA, QB, QC, QD};
    integer    e, i, errors, checks;
    reg [31:0] lfsr;

`ifdef SCH
    univ74194_sch dut (.SLSI(SLSI), .SRSI(SRSI), .In(In), .S0(S0), .S1(S1), .ClrN(ClrN), .Clk(Clk),
                       .QA(QA), .QB(QB), .QC(QC), .QD(QD));
`else
    univ74194     dut (.SLSI(SLSI), .SRSI(SRSI), .In(In), .S0(S0), .S1(S1), .ClrN(ClrN), .Clk(Clk),
                       .QA(QA), .QB(QB), .QC(QC), .QD(QD));
`endif

    task compare (input [3:0] exp, input [8*10-1:0] tag);
        begin
            checks = checks + 1;
            if (Q !== exp) begin
                errors = errors + 1;
                $display("   ** mismatch (%0s): got %b expected %b", tag, Q, exp);
            end
        end
    endtask

    task clock_once;
        begin
            #10 Clk = 0;
            #10 Clk = 1;          // 상승 에지
            #10;
        end
    endtask

    function [8*5-1:0] mode (input s1, input s0);
        mode = {s1, s0} == 2'b00 ? "hold " : {s1, s0} == 2'b01 ? "right" : {s1, s0} == 2'b10 ? "left " : "load ";
    endfunction

    // 예제 12-7 (에지 1 → 5): S1 S0, SR, SL, 답
    reg [9:0]  ex_s  = 10'b11_01_01_10_00;
    reg [4:0]  ex_sr = 5'b0_1_0_0_0;
    reg [4:0]  ex_sl = 5'b0_0_0_1_1;
    reg [19:0] ex_q  = 20'b1100_1110_0111_1111_1111;

    initial begin
        errors = 0; checks = 0; lfsr = 32'h2468_ACE1;
        SLSI = 0; SRSI = 0; S0 = 0; S1 = 0; ClrN = 1; Clk = 1; In = 4'b0000;
        #10 $display(" start : QA QB QC QD = %b (unknown)", Q);
        ClrN = 0; #10; compare(4'b0000, "clear"); ClrN = 1; #10;
        $display(" clear : QA QB QC QD = %b", Q);

        // 예제 12-7 : 처음 0000, A B C D = 1100
        In = 4'b1100;
        $display(" [ex 12-7] edge | S1 S0 SR SL (mode) | QA QB QC QD | expected");
        for (i = 0; i < 5; i = i + 1) begin
            {S1, S0} = ex_s[9 - 2*i -: 2]; SRSI = ex_sr[4 - i]; SLSI = ex_sl[4 - i];
            clock_once;
            $display("            %0d   |  %b  %b  %b  %b (%s) |    %b     |   %b",
                     i + 1, S1, S0, SRSI, SLSI, mode(S1, S0), Q, ex_q[19 - 4*i -: 4]);
            compare(ex_q[19 - 4*i -: 4], "ex 12-7");
        end

        // 비동기 클리어
        ClrN = 0; #5; compare(4'b0000, "async clr"); #5; ClrN = 1; #10;
        $display(" ClrN=0 (no clock) : %b", Q);

        // 무작위 40 에지
        e = 0;
        for (i = 0; i < 40; i = i + 1) begin
            lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
            {S1, S0} = lfsr[1:0]; SRSI = lfsr[2]; SLSI = lfsr[3]; In = lfsr[7:4];
            clock_once;
            case ({S1, S0})
                2'b00: e = e;
                2'b01: e = e / 2 + 8 * SRSI;
                2'b10: e = (2 * e) % 16 + SLSI;
                2'b11: e = In;
            endcase
            compare(e, "random");
        end
        $display(" random 40 edges : done");
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
