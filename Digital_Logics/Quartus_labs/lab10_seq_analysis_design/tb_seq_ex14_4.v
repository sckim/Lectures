// tb_seq_ex14_4.v : 예제 14-4 회로 테스트벤치 (Lab 10 Part A)
// 기대값은 14.5.2절의 상태표(형식 ②)를 상수 배열로 옮겨 계산한다. DUT의 식은 쓰지 않는다.
// 순서
//   1) ClrN = 0 : A B = 00
//   2) 예제 14-8 : 상승 에지 직전의 x가 0 1 1 0 0 0 1 1 1. 5번째와 6번째 에지 사이에 x에 짧은 펄스
//                  (무어 출력 z는 펄스에 반응하지 않아야 한다)
//   3) 의사 난수 x로 클럭 48번. (상태, x) 8가지가 모두 한 번 이상 나왔는지도 검사한다
// 입력 x는 CLK = 0인 동안(에지에서 떨어진 시각)에 바꾼다. 상태는 에지 뒤에 확인한다.
//   +define+SCH : 회로도 netlist(seq_d_ex14_4_sch)를 검사
`timescale 1ns/1ps
module tb_seq_ex14_4;
    reg  CLK = 0, ClrN = 1, X = 0;
    wire A, B, Z;
`ifdef SCH
    seq_d_ex14_4_sch dut (.CLK(CLK), .ClrN(ClrN), .X(X), .A(A), .B(B), .Z(Z));
`else
    seq_d_ex14_4     dut (.CLK(CLK), .ClrN(ClrN), .X(X), .A(A), .B(B), .Z(Z));
`endif
    // 상태표 (14.5.2절)   현재 AB | 차기 x=0 | 차기 x=1 | z
    //                      00     |   10     |   01     | 0
    //                      01     |   00     |   11     | 1
    //                      10     |   11     |   01     | 1
    //                      11     |   01     |   11     | 0
    reg [1:0] NEXT [0:7];          // 인덱스 {A, B, x}
    reg       ZOUT [0:3];          // 인덱스 {A, B}
    reg [1:0] s;                   // 기대 상태
    reg [7:0] seen;                // 지나간 (상태, x) 조합
    reg [31:0] lfsr;
    integer i, errors, checks;
    reg [8:0] ex8 = 9'b0_1_1_0_0_0_1_1_1;   // 예제 14-8의 x (↑1이 맨 왼쪽)

    task check(input [8*10-1:0] tag);
        begin
            checks = checks + 1;
            if ({A, B} !== s || Z !== ZOUT[s]) begin
                errors = errors + 1;
                $display("   ** mismatch (%0s): AB=%b%b Z=%b, expected AB=%b Z=%b", tag, A, B, Z, s, ZOUT[s]);
            end
        end
    endtask

    // 클럭 한 번: x를 정하고(CLK = 0), 상승 에지, 기대 상태 갱신, 확인
    task step(input xv, input pulse);
        reg [1:0] cur;
        begin
            X = xv; #5;
            if (pulse) begin                        // 클럭 주기 중간의 짧은 펄스
                X = ~xv; #2; checks = checks + 1;
                if (Z !== ZOUT[s]) begin errors = errors + 1; $display("   ** Z changed with x pulse"); end
                X = xv;  #3;
            end
            cur = s; seen[{cur, xv}] = 1'b1;
            CLK = 1; #1; s = NEXT[{cur, xv}]; #4;
            CLK = 0; #5;
        end
    endtask

    initial begin
        NEXT[0] = 2'b10; NEXT[1] = 2'b01;   // 00
        NEXT[2] = 2'b00; NEXT[3] = 2'b11;   // 01
        NEXT[4] = 2'b11; NEXT[5] = 2'b01;   // 10
        NEXT[6] = 2'b01; NEXT[7] = 2'b11;   // 11
        ZOUT[0] = 0; ZOUT[1] = 1; ZOUT[2] = 1; ZOUT[3] = 0;
        errors = 0; checks = 0; seen = 0; lfsr = 32'h1357_9BDF;
        #5;
        $display(" start     : A B = %b %b (unknown before ClrN)", A, B);
        ClrN = 0; #5; s = 2'b00; check("clear");
        $display(" ClrN=0    : A B = %b %b, Z = %b", A, B, Z);
        ClrN = 1; #5;
        $display(" [Example 14-8]");
        $display("  edge | AB before | z | x | AB after | expected");
        for (i = 8; i >= 0; i = i - 1) begin : ex
            reg [1:0] before; reg zb;
            before = {A, B}; zb = Z;
            step(ex8[i], (i == 3));                  // ↑5와 ↑6 사이(5번째 step 뒤)에 펄스
            $display("   %0d   |    %b%b     | %b | %b |    %b%b    |   %b", 9 - i, before[1], before[0], zb, ex8[i], A, B, s);
            check("ex 14-8");
        end
        for (i = 0; i < 48; i = i + 1) begin
            lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
            step(lfsr[0], 1'b0); check("random");
        end
        checks = checks + 1;
        if (seen !== 8'hFF) begin errors = errors + 1; $display("   ** not all (state, x) pairs visited: %b", seen); end
        $display(" random 48 clocks : done, (state, x) pairs visited = %b", seen);
        ClrN = 0; #5; s = 2'b00; check("clear 2"); ClrN = 1; #5;
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
