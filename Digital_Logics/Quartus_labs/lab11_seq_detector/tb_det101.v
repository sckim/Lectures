// tb_det101.v : 101 검출기 세 구현(손 설계 회로, Mealy FSM, Moore FSM) 비교 테스트벤치 (Lab 11 Part C)
// 기대값은 DUT와 독립적으로 "지금까지 받아들인 입력 열"에서 직접 계산한다.
//   Mealy : 이번 주기의 x와 앞의 두 입력이 1 0 1이면 1            (중첩 허용)
//   Moore : 한 주기 앞의 Mealy 기대값 (한 클럭 늦다)
// 처음 16주기는 19.2.1절 표의 상태 열(상수)과도 비교한다.
// x는 클럭 하강 에지에서 바꾸고, 출력은 다음 상승 에지 1 ns 전에 읽는다(19.7.4절과 같은 방법).
// 순서: ① ClrN = 0 → 1  ② 19.2.1절 입력 열 16비트  ③ 주기 중간에 ClrN = 0 (비동기 리셋)  ④ 의사 난수 200비트
//   +define+SCH : 손 설계 쪽은 회로도 netlist(det101_hand_sch)를 검사
`timescale 1ns/1ps
module tb_det101;
    reg  CLK = 0, ClrN = 0, X = 0;
    wire Z_hand, A, B, Z_MEALY, Z_MOORE;
    wire [1:0] ST_MEALY, ST_MOORE;
`ifdef SCH
    det101_hand_sch u_hand (.CLK(CLK), .ClrN(ClrN), .X(X), .Z(Z_hand), .A(A), .B(B));
`else
    det101_hand     u_hand (.CLK(CLK), .ClrN(ClrN), .X(X), .Z(Z_hand), .A(A), .B(B));
`endif
    det101_fsm_top  u_fsm  (.CLK(CLK), .ClrN(ClrN), .X(X), .Z_MEALY(Z_MEALY), .Z_MOORE(Z_MOORE),
                            .ST_MEALY(ST_MEALY), .ST_MOORE(ST_MOORE));

    always #10 CLK = ~CLK;                     // 주기 20 ns, 상승 에지 10, 30, 50 ... ns

    reg [15:0] seq   = 16'b0011011001010100;  // 19.2.1절 표의 X (왼쪽 비트가 주기 0)
    // 19.2.1절 표의 상태 (S0 = 0, S1 = 1, S2 = 2, S3 = 3), 주기 0이 맨 왼쪽
    reg [31:0] st_me = {2'd0,2'd0,2'd0,2'd1,2'd1,2'd2,2'd1,2'd1,2'd2,2'd0,2'd1,2'd2,2'd1,2'd2,2'd1,2'd2};
    reg [31:0] st_mo = {2'd0,2'd0,2'd0,2'd1,2'd1,2'd2,2'd3,2'd1,2'd2,2'd0,2'd1,2'd2,2'd3,2'd2,2'd3,2'd2};

    reg  h1, h2;          // 앞 주기, 두 주기 전에 받아들인 입력
    integer n;            // 리셋 뒤 받아들인 입력 수
    reg  e_mealy, e_moore;
    integer k, errors, checks, hits_me, hits_mo;
    reg [31:0] lfsr;

    task cycle(input xv, input show, input integer kk);
        begin
            @(negedge CLK) X = xv;
            #9;                                        // 상승 에지 1 ns 전
            e_mealy = (n >= 2) && h2 && !h1 && xv;
            checks = checks + 1;
            if (Z_MEALY !== e_mealy || Z_hand !== e_mealy || Z_MOORE !== e_moore || {A, B} !== ST_MEALY) begin
                errors = errors + 1;
                $display("   ** mismatch at k=%0d: hand %b mealy %b moore %b (exp %b %b), AB %b%b mealy st %b",
                         kk, Z_hand, Z_MEALY, Z_MOORE, e_mealy, e_moore, A, B, ST_MEALY);
            end
            if (show) begin
                checks = checks + 1;
                if (ST_MEALY !== st_me[31-2*kk -: 2] || ST_MOORE !== st_mo[31-2*kk -: 2]) begin
                    errors = errors + 1; $display("   ** state differs from the 19.2.1 table at k=%0d", kk);
                end
                $display(" %2d | %b |   %b   %b   |   %b   %b   |  %b%b  %b   | %b %b",
                         kk, xv, ST_MEALY, Z_MEALY, ST_MOORE, Z_MOORE, A, B, Z_hand, e_mealy, e_moore);
            end
            hits_me = hits_me + Z_MEALY; hits_mo = hits_mo + Z_MOORE;
            @(posedge CLK);                            // 입력을 받아들이는 순간
            e_moore = e_mealy;                         // 무어 출력은 다음 주기에 나타난다
            h2 = h1; h1 = xv; n = n + 1;
        end
    endtask

    initial begin
        errors = 0; checks = 0; hits_me = 0; hits_mo = 0; lfsr = 32'hC0DE_1234;
        h1 = 0; h2 = 0; n = 0; e_moore = 0;
        #5 ClrN = 1;                                   // 5 ns에 리셋 해제
        $display("  k | x | Mealy st z | Moore st z | hand AB z | expected Mealy Moore");
        for (k = 0; k < 16; k = k + 1) cycle(seq[15-k], 1'b1, k);
        $display(" detections in the 16 cycles: Mealy %0d, Moore %0d", hits_me, hits_mo);
        // 주기 중간의 비동기 리셋
        @(negedge CLK) X = 1; #3 ClrN = 0; #2;
        checks = checks + 1;
        if (ST_MEALY !== 2'b00 || ST_MOORE !== 2'b00 || {A, B} !== 2'b00) begin
            errors = errors + 1; $display("   ** ClrN did not reset all states");
        end
        $display(" ClrN = 0 in mid-cycle : Mealy st %b, Moore st %b, hand AB %b%b", ST_MEALY, ST_MOORE, A, B);
        @(posedge CLK); #2 ClrN = 1;                   // 에지에서 떨어진 시각에 해제
        h1 = 0; h2 = 0; n = 0; e_moore = 0; hits_me = 0; hits_mo = 0;
        for (k = 0; k < 200; k = k + 1) begin
            lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
            cycle(lfsr[0] | lfsr[3], 1'b0, k);         // 1이 조금 더 자주 나오게
        end
        $display(" random 200 cycles : detections Mealy %0d, Moore %0d", hits_me, hits_mo);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
