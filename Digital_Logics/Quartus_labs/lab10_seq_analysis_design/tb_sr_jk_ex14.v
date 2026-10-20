// tb_sr_jk_ex14.v : 예제 14-3(SR) 회로와 예제 14-6(JK) 회로 테스트벤치 (Lab 10 Part B)
// 두 회로에 같은 x와 클럭을 넣고, 둘 다 14.4절의 상태표(상수 배열)와 같은지 확인한다.
// SR 회로의 밀리 출력 Y는 에지 직전(입력이 안정된 때)에 상태표의 y와 비교한다.
// 순서
//   1) ClrN = 0 : 두 회로 모두 A B = 00
//   2) 예제 14-9의 x (에지 직전 값 1 0 0 0 1 1 0 1). 3번째와 4번째 에지 사이(상태 10)에서 x에 짧은 1 펄스
//      -> 상태는 그대로인데 Y에만 짧은 1이 나와야 한다(밀리 출력)
//   3) 의사 난수 x로 클럭 48번. (상태, x) 8가지가 모두 나왔는지 검사
//   +define+SCH : 회로도 netlist(seq_sr_ex14_3_sch, seq_jk_ex14_6_sch)를 검사
`timescale 1ns/1ps
module tb_sr_jk_ex14;
    reg  CLK = 0, ClrN = 1, X = 0;
    wire Y, A_sr, B_sr, A_jk, B_jk;
`ifdef SCH
    seq_sr_ex14_3_sch u_sr (.CLK(CLK), .ClrN(ClrN), .X(X), .Y(Y), .A(A_sr), .B(B_sr));
    seq_jk_ex14_6_sch u_jk (.CLK(CLK), .ClrN(ClrN), .X(X), .A(A_jk), .B(B_jk));
`else
    seq_sr_ex14_3     u_sr (.CLK(CLK), .ClrN(ClrN), .X(X), .Y(Y), .A(A_sr), .B(B_sr));
    seq_jk_ex14_6     u_jk (.CLK(CLK), .ClrN(ClrN), .X(X), .A(A_jk), .B(B_jk));
`endif
    // 상태표 (14.4절 형식 ②)  현재 AB | 차기 x=0 | 차기 x=1 | y x=0 | y x=1
    //                          00     |   00     |   01     |   0   |   0
    //                          01     |   11     |   01     |   0   |   0
    //                          10     |   10     |   00     |   0   |   1
    //                          11     |   10     |   11     |   0   |   0
    reg [1:0] NEXT [0:7];          // 인덱스 {A, B, x}
    reg [7:0] YT = 8'b0010_0000;   // y = 1 은 {A,B,x} = 101 한 칸뿐
    reg [1:0] s;
    reg [7:0] seen;
    reg [31:0] lfsr;
    integer i, errors, checks;
    reg [7:0] ex9 = 8'b1_0_0_0_1_1_0_1;   // 예제 14-9의 x (에지 직전 값, 1번째 에지가 맨 왼쪽)

    task check_state(input [8*10-1:0] tag);
        begin
            checks = checks + 1;
            if ({A_sr, B_sr} !== s || {A_jk, B_jk} !== s) begin
                errors = errors + 1;
                $display("   ** mismatch (%0s): SR AB=%b%b JK AB=%b%b expected %b", tag, A_sr, B_sr, A_jk, B_jk, s);
            end
        end
    endtask

    task check_y(input [8*10-1:0] tag);
        begin
            checks = checks + 1;
            if (Y !== YT[{s, X}]) begin
                errors = errors + 1;
                $display("   ** Y mismatch (%0s): state %b x %b Y=%b expected %b", tag, s, X, Y, YT[{s, X}]);
            end
        end
    endtask

    integer ypulse;   // 펄스 동안 본 Y
    reg     Y_before; // 에지 직전에 본 Y
    task step(input xv, input pulse);
        reg [1:0] cur;
        begin
            ypulse = -1;
            if (pulse) begin                         // 주기 중간의 짧은 펄스 (상태가 바뀌지 않는 구간)
                X = ~xv; #2; check_y("pulse"); ypulse = Y; X = xv; #2;
            end
            X = xv; #4;
            check_y("before edge");                  // 에지 직전에 읽은 밀리 출력
            Y_before = Y;
            cur = s; seen[{cur, xv}] = 1'b1;
            CLK = 1; #1; s = NEXT[{cur, xv}]; #4;
            CLK = 0; #5;
            check_state("edge");
        end
    endtask

    initial begin
        NEXT[0] = 2'b00; NEXT[1] = 2'b01;   // 00
        NEXT[2] = 2'b11; NEXT[3] = 2'b01;   // 01
        NEXT[4] = 2'b10; NEXT[5] = 2'b00;   // 10
        NEXT[6] = 2'b10; NEXT[7] = 2'b11;   // 11
        errors = 0; checks = 0; seen = 0; lfsr = 32'h2468_ACE1;
        #5;
        $display(" start  : SR AB = %b%b, JK AB = %b%b (unknown)", A_sr, B_sr, A_jk, B_jk);
        ClrN = 0; #5; s = 2'b00; check_state("clear");
        $display(" ClrN=0 : SR AB = %b%b, JK AB = %b%b", A_sr, B_sr, A_jk, B_jk);
        ClrN = 1; #5;
        $display(" [Example 14-9 input]");
        $display("  edge | AB | x (Y before edge) | SR AB  JK AB | expected | note");
        for (i = 7; i >= 0; i = i - 1) begin : ex
            reg [1:0] before; reg yb;
            before = s;
            step(ex9[i], (i == 4));                   // 4번째 에지 앞(상태 10)에서 펄스
            if (ypulse >= 0)
                $display("   %0d   | %b | %b (%b)             |  %b%b    %b%b  |    %b     | x pulse 0->1->0 before this edge: Y = %0d during the pulse",
                         8 - i, before, ex9[i], Y_before, A_sr, B_sr, A_jk, B_jk, s, ypulse);
            else
                $display("   %0d   | %b | %b (%b)             |  %b%b    %b%b  |    %b     |",
                         8 - i, before, ex9[i], Y_before, A_sr, B_sr, A_jk, B_jk, s);
        end
        for (i = 0; i < 48; i = i + 1) begin
            lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
            step(lfsr[0], lfsr[5] & lfsr[9]);
        end
        checks = checks + 1;
        if (seen !== 8'hFF) begin errors = errors + 1; $display("   ** not all (state, x) pairs visited: %b", seen); end
        $display(" random 48 clocks : done, (state, x) pairs visited = %b", seen);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
