// tb_piso.v : 8비트 PISO 74165 테스트벤치 (Lab 08 Part B)
// 기대값은 DUT와 따로 계산한다(정수 산술 모델).
//   e = 8비트 정수, 가장 큰 자리(128)가 QA, 1의 자리가 QH
//   로드: e = {A..H},  시프트: e = e/2 + 128*SI,  QH = e % 2,  QHn = 1 - QH
// 1) 예제 12-4를 8비트로 늘린 것: A–H = 1010 0110 로드, SI = 1 → QH가 H, G, F, … , A, 그다음 1
// 2) CLK INH = 1인 동안 클럭이 와도 시프트하지 않는다
// 3) 무작위 로드·시프트·인히비트 40번
// 클럭은 KEY0처럼 준다(떼는 순간 상승 에지). 로드는 KEY1을 누르는 것(Shift_load = 0)이다.
//   +define+SCH : 회로도 netlist(piso74165_sch)를 검사
`timescale 1ns/1ps
module tb_piso;
    reg  Clk, SI, A, B, C, D, E, F, G, H, Shift_load, Clk_Inhibit;
    wire QH, QHn;
    integer e, i, k, errors, checks;
    reg [31:0] lfsr;
    reg [7:0] data;

`ifdef SCH
    piso74165_sch dut (.Clk(Clk), .SI(SI), .A(A), .B(B), .C(C), .D(D), .E(E), .F(F), .G(G), .H(H),
                       .Shift_load(Shift_load), .Clk_Inhibit(Clk_Inhibit), .QH(QH), .QHn(QHn));
`else
    piso74165     dut (.Clk(Clk), .SI(SI), .A(A), .B(B), .C(C), .D(D), .E(E), .F(F), .G(G), .H(H),
                       .Shift_load(Shift_load), .Clk_Inhibit(Clk_Inhibit), .QH(QH), .QHn(QHn));
`endif

    task compare (input [8*10-1:0] tag);
        begin
            checks = checks + 1;
            if (QH !== e % 2 || QHn !== 1 - e % 2) begin
                errors = errors + 1;
                $display("   ** mismatch (%0s): QH QHn = %b %b expected %0d %0d", tag, QH, QHn, e % 2, 1 - e % 2);
            end
        end
    endtask

    task clock_once;
        begin
            #10 Clk = 0;
            #10 Clk = 1;          // 상승 에지
            #10;
            if (!Clk_Inhibit) e = e / 2 + 128 * SI;
        end
    endtask

    task load (input [7:0] v);   // KEY1을 눌렀다 뗀다. 누르는 동안 A–H는 바꾸지 않는다
        begin
            {A, B, C, D, E, F, G, H} = v;
            #5 Shift_load = 0; #10;
            e = v;
            compare("load");     // 클럭 없이 이미 실려 있어야 한다 (비동기 로드)
            Shift_load = 1; #10;
        end
    endtask

    initial begin
        errors = 0; checks = 0; lfsr = 32'h0F1E_2D3C;
        Clk = 1; SI = 0; {A, B, C, D, E, F, G, H} = 8'h00; Shift_load = 1; Clk_Inhibit = 0;
        #10 $display(" start : QH = %b (unknown)", QH);

        // 1) 1010 0110 로드, SI = 1
        SI = 1; load(8'b1010_0110);
        $display(" [load A-H = 10100110, SI = 1]");
        $display("  step | QH QHn | expected QH | (bit that should appear)");
        $display("  load |  %b  %b  |      %0d      | H", QH, QHn, e % 2);
        for (i = 1; i <= 10; i = i + 1) begin
            clock_once; compare("ex 12-4");
            $display("  sh%-2d |  %b  %b  |      %0d      | %s", i, QH, QHn, e % 2,
                     i == 1 ? "G " : i == 2 ? "F " : i == 3 ? "E " : i == 4 ? "D " : i == 5 ? "C " :
                     i == 6 ? "B " : i == 7 ? "A " : "SI");
        end

        // 2) CLK INH
        SI = 0; load(8'b1100_1011);
        clock_once; compare("before INH");                  // QH = G = 1
        Clk_Inhibit = 1; #10;
        for (i = 0; i < 3; i = i + 1) begin clock_once; compare("INH=1"); end
        $display(" CLK INH = 1, 3 clocks : QH = %b (expected %0d, no shift)", QH, e % 2);
        Clk_Inhibit = 0; #10;
        clock_once; compare("after INH");
        $display(" CLK INH = 0, 1 clock  : QH = %b (expected %0d)", QH, e % 2);

        // 3) 무작위 40번
        for (k = 0; k < 40; k = k + 1) begin
            lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
            if (lfsr[2:0] == 3'b000) begin data = lfsr[15:8]; load(data); end
            else begin
                SI = lfsr[4]; Clk_Inhibit = (lfsr[7:5] == 3'b111); #10;
                clock_once; compare("random");
                Clk_Inhibit = 0; #10;
            end
        end
        $display(" random 40 steps : done");
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
