// tb_ripple.v : 3비트 리플 업·다운 카운터 테스트벤치 (Lab 09 Part B)
// 두 카운터에 같은 클럭(n_cp)과 클리어(ClrN)를 넣는다.
// 기대값은 클리어 뒤 누른 횟수 k로 따로 계산한다:  업 = k mod 8,  다운(Q̄에서 읽기) = 7 − (k mod 8)
// 클럭은 KEY0처럼 준다. n_cp가 1 → 0으로 바뀌는 순간(누름)이 하강 에지이고 카운터가 바뀐다.
//   +define+SCH : 회로도 netlist(ripple3_sch, ripple3_down_sch)를 검사
`timescale 1ns/1ps
module tb_ripple;
    reg  n_cp, ClrN;
    wire [2:0] Qu, Qd;
    integer k, i, errors, checks;

`ifdef SCH
    ripple3_sch      u_up (.n_cp(n_cp), .ClrN(ClrN), .Q(Qu));
    ripple3_down_sch u_dn (.n_cp(n_cp), .ClrN(ClrN), .Q(Qd));
`else
    ripple3          u_up (.n_cp(n_cp), .ClrN(ClrN), .Q(Qu));
    ripple3_down     u_dn (.n_cp(n_cp), .ClrN(ClrN), .Q(Qd));
`endif

    task check;
        begin
            checks = checks + 2;
            if (Qu !== k % 8)     begin errors = errors + 1; $display("   ** up   k=%0d got %0d", k, Qu); end
            if (Qd !== 7 - k % 8) begin errors = errors + 1; $display("   ** down k=%0d got %0d", k, Qd); end
        end
    endtask

    task press;            // KEY0을 누른다(하강 에지) → 10 ns 뒤에 본다 → 뗀다
        begin
            #10 n_cp = 0; #10; k = k + 1; check;
            #10 n_cp = 1; #10; check;      // 떼는 순간(상승 에지)에는 바뀌지 않아야 한다
        end
    endtask

    initial begin
        errors = 0; checks = 0; k = 0;
        n_cp = 1; ClrN = 1;
        #10 $display(" start : up = %b, down = %b (unknown)", Qu, Qd);
        ClrN = 0; #10; check; ClrN = 1; #10;
        $display(" press | up  QC QB QA (dec) | down QC QB QA (dec)");
        $display("  clr  |      %b (%0d)      |      %b (%0d)", Qu, Qu, Qd, Qd);
        for (i = 1; i <= 18; i = i + 1) begin
            press;
            if (i <= 9) $display("   %2d  |      %b (%0d)      |      %b (%0d)", i, Qu, Qu, Qd, Qd);
        end
        // 세는 도중의 비동기 클리어
        ClrN = 0; #5; k = 0; check; #5; ClrN = 1; #10;
        $display(" ClrN=0 in the middle : up = %b, down = %b", Qu, Qd);
        for (i = 1; i <= 5; i = i + 1) press;
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
