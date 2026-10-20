// tb_johnson_lockout.v : 예제 16-2 미사용 상태 실험 테스트벤치 (Lab 10 Part E)
// 8개 상태 각각에서 출발시켜 두 회로(don't care 설계, 고친 설계)가 16.1.4절의 표대로 움직이는지 본다.
// 기대값은 16.1.4절의 다음 상태표를 상수 배열로 옮겨 계산한다(DUT의 식을 쓰지 않는다).
//   don't care 설계 : 정상 6상태 + 010 -> 101, 101 -> 010 (록아웃)
//   고친 설계       : 정상 6상태 + 010 -> 100, 101 -> 010
// 정상 루프 000 -> 100 -> 110 -> 111 -> 011 -> 001 -> 000
//   +define+SCH : 회로도 netlist(johnson_lockout_sch)를 검사
`timescale 1ns/1ps
module tb_johnson_lockout;
    reg  CLK = 0, LoadN = 1, S2 = 0, S1 = 0, S0 = 0;
    wire A1, B1, C1, A2, B2, C2;
`ifdef SCH
    johnson_lockout_sch dut (.CLK(CLK), .LoadN(LoadN), .S2(S2), .S1(S1), .S0(S0),
                             .A1(A1), .B1(B1), .C1(C1), .A2(A2), .B2(B2), .C2(C2));
`else
    johnson_lockout     dut (.CLK(CLK), .LoadN(LoadN), .S2(S2), .S1(S1), .S0(S0),
                             .A1(A1), .B1(B1), .C1(C1), .A2(A2), .B2(B2), .C2(C2));
`endif
    reg [2:0] NL [0:7];     // don't care 설계의 다음 상태 (인덱스 ABC)
    reg [2:0] NF [0:7];     // 고친 설계의 다음 상태
    reg [2:0] e1, e2;       // 기대 상태
    integer st, k, errors, checks, enter1, enter2;

    function normal(input [2:0] q);      // 정상 루프에 있는 상태인가
        normal = (q != 3'b010) && (q != 3'b101);
    endfunction

    task check(input [8*8-1:0] tag);
        begin
            checks = checks + 1;
            if ({A1, B1, C1} !== e1 || {A2, B2, C2} !== e2) begin
                errors = errors + 1;
                $display("   ** mismatch (%0s): lock %b%b%b fix %b%b%b expected %b %b", tag, A1, B1, C1, A2, B2, C2, e1, e2);
            end
        end
    endtask

    initial begin
        NL[3'b000] = 3'b100; NL[3'b100] = 3'b110; NL[3'b110] = 3'b111;
        NL[3'b111] = 3'b011; NL[3'b011] = 3'b001; NL[3'b001] = 3'b000;
        NL[3'b010] = 3'b101; NL[3'b101] = 3'b010;
        for (k = 0; k < 8; k = k + 1) NF[k] = NL[k];
        NF[3'b010] = 3'b100;                     // 고친 설계: 010의 다음 상태를 100으로 정함
        errors = 0; checks = 0;
        #5;
        $display(" start | don't care design (DC = B)       | fixed design (DC = B(A+C))");
        for (st = 0; st < 8; st = st + 1) begin
            {S2, S1, S0} = st[2:0];
            LoadN = 0; #5; e1 = st[2:0]; e2 = st[2:0]; check("load"); LoadN = 1; #5;
            enter1 = normal(e1) ? 0 : -1; enter2 = normal(e2) ? 0 : -1;
            $write("  %b  | %b", st[2:0], e1);
            for (k = 1; k <= 7; k = k + 1) begin
                #5 CLK = 1; #1 e1 = NL[e1]; e2 = NF[e2]; #4 CLK = 0; #5;
                check("clock");
                if (enter1 < 0 && normal(e1)) enter1 = k;
                if (enter2 < 0 && normal(e2)) enter2 = k;
                $write(" %b", {A1, B1, C1});
            end
            // 7클럭 동안의 두 번째 회로 경로를 같은 줄에 한 번 더 찍는다
            $write(" | ");
            {S2, S1, S0} = st[2:0];
            LoadN = 0; #5; LoadN = 1; #5;   // 다시 실어서 고친 설계의 경로를 보인다
            e1 = st[2:0]; e2 = st[2:0];
            $write("%b", {A2, B2, C2});
            for (k = 1; k <= 7; k = k + 1) begin
                #5 CLK = 1; #1 e1 = NL[e1]; e2 = NF[e2]; #4 CLK = 0; #5;
                check("clock");
                $write(" %b", {A2, B2, C2});
            end
            $display("");
            $display("        enters normal loop after: don't care = %0s, fixed = %0d clock(s)",
                     (enter1 < 0) ? "never" : (enter1 == 0) ? "0" : (enter1 == 1) ? "1" : "2+", enter2);
            // 판정: don't care 설계는 010, 101에서 영영 못 들어가고, 고친 설계는 2클럭 안에 들어가야 한다
            checks = checks + 1;
            if (((st == 3'b010 || st == 3'b101) ? (enter1 != -1) : (enter1 != 0)) || enter2 < 0 || enter2 > 2) begin
                errors = errors + 1; $display("   ** self-start judgement failed for start %b", st[2:0]);
            end
        end
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
