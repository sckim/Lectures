// tb_sync4.v : 4비트 동기식 2진 카운터 테스트벤치 (Lab 09 Part D)
// 기대값 = (클리어 뒤 상승 에지 수) mod 16 (정수 산술). 0 → 15 → 0을 한 바퀴 넘게 센다.
// 각 에지 뒤에 "바뀐 비트"도 출력해 17.5.1절의 규칙(아래 비트가 모두 1인 비트만 토글)을 눈으로 본다.
// 클럭은 KEY0처럼 준다(떼는 순간 상승 에지).
//   +define+SCH : 회로도 netlist(sync4_sch)를 검사
`timescale 1ns/1ps
module tb_sync4;
    reg  Cp, ClrN;
    wire Qa, Qb, Qc, Qd;
    wire [3:0] Q = {Qd, Qc, Qb, Qa};
    reg  [3:0] prev;
    integer k, errors, checks;

`ifdef SCH
    sync4_sch dut (.Cp(Cp), .ClrN(ClrN), .Qa(Qa), .Qb(Qb), .Qc(Qc), .Qd(Qd));
`else
    sync4     dut (.Cp(Cp), .ClrN(ClrN), .Qa(Qa), .Qb(Qb), .Qc(Qc), .Qd(Qd));
`endif

    task clock_once;
        begin #10 Cp = 0; #10 Cp = 1; #10; end
    endtask

    initial begin
        errors = 0; checks = 0;
        Cp = 1; ClrN = 1;
        #10 $display(" start : QD QC QB QA = %b (unknown)", Q);
        ClrN = 0; #10; checks = checks + 1; if (Q !== 4'd0) errors = errors + 1; ClrN = 1; #10;
        $display(" edge | QD QC QB QA (dec) | toggled bits (D C B A)");
        for (k = 1; k <= 20; k = k + 1) begin
            prev = Q;
            clock_once;
            checks = checks + 1;
            if (Q !== k % 16) begin errors = errors + 1; $display("   ** k=%0d got %b", k, Q); end
            $display("  %2d  |    %b (%2d)     |   %b", k, Q, Q, Q ^ prev);
        end
        ClrN = 0; #5; checks = checks + 1; if (Q !== 4'd0) errors = errors + 1; #5; ClrN = 1; #10;
        $display(" ClrN=0 (no clock) : %b", Q);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
