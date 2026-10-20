// tb_safe.v : 디지털 금고 테스트벤치 (Lab 12 선택 과제 2, 22.6절, 예제 22-2)
//   비밀번호 7-2-5. 세 자리 입력 000..999 1000가지를 모두 넣는다. 매번 KEY[0](잠금)으로 처음 상태에서 시작한다.
//   기대값: (1) 첫째·둘째 자리 뒤에는 open = alarm = 0 (틀린 자리를 알려 주지 않는다)
//           (2) 셋째 자리 뒤 open = (입력 == 725), alarm = (입력 != 725)
//           (3) 그 뒤 넷째 입력은 무시된다 (OPEN, FAIL은 잠글 때까지 유지)
//   입력 한 자리: 하강 에지에서 d를 놓고 ent를 한 클럭 동안 1로 (btn_edge의 출력과 같은 1클럭 펄스)
`timescale 1ns/1ps
module tb_safe;
    reg clk = 0, rst_n = 0, ent = 0;
    reg [3:0] d = 0;
    always #10 clk = ~clk;
    wire open, alarm;
    safe dut (.clk(clk), .rst_n(rst_n), .ent(ent), .d(d), .open(open), .alarm(alarm));

    integer a, b, c, errors = 0, checks = 0, opens = 0, alarms = 0;
    task enter (input [3:0] x);
        begin
            @(negedge clk) begin d = x; ent = 1; end
            @(negedge clk) ent = 0;
            @(negedge clk);
        end
    endtask
    task check (input got, input exp);
        begin checks = checks + 1; if (got !== exp) errors = errors + 1; end
    endtask

    initial begin
        for (a = 0; a < 10; a = a + 1)
            for (b = 0; b < 10; b = b + 1)
                for (c = 0; c < 10; c = c + 1) begin
                    @(negedge clk) rst_n = 0;            // 잠금
                    @(negedge clk) rst_n = 1;
                    enter(a); check(open, 0); check(alarm, 0);
                    enter(b); check(open, 0); check(alarm, 0);
                    enter(c);
                    check(open,  (a == 7 && b == 2 && c == 5));
                    check(alarm, !(a == 7 && b == 2 && c == 5));
                    opens = opens + open; alarms = alarms + alarm;
                    enter(7);                            // 넷째 입력: 무시되어야 한다
                    check(open,  (a == 7 && b == 2 && c == 5));
                    check(alarm, !(a == 7 && b == 2 && c == 5));
                    if ((a == 7 && b == 2 && c == 5) || (a == 7 && b == 3 && c == 5) || (a == 1 && b == 2 && c == 5)
                        || (a == 7 && b == 2 && c == 4) || (a == 2 && b == 7 && c == 5))
                        $display("  input %0d %0d %0d -> open %b alarm %b", a, b, c, open, alarm);
                end
        $display("  1000 inputs: opened %0d, alarm %0d", opens, alarms);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
