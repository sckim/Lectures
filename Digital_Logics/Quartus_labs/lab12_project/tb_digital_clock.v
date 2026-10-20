// tb_digital_clock.v : 디지털 시계 통합 테스트벤치 (Lab 12 Part B, 22.4절, 22.7.1절)
//   분주비 N = 4 (4클럭 = 1초). 보드와 같게 KEY는 누르면 0, HEX 세그먼트는 0 = 켜짐.
//   기대값은 DUT와 따로 "자정부터 지난 초" 정수 t 하나로 계산한다.
//     - 리셋을 푼 뒤 e번째 상승 에지에서 (e - 1)이 N의 배수이고 e > 1이면 1초가 지난다
//       (분주기가 N번째 에지에서 tick을 내고, 카운터는 그다음 에지에서 센다)
//     - 설정 모드(SW[0] = 1)에서는 초가 멈추고, KEY[1]을 누를 때마다 분 +1(시는 그대로),
//       KEY[2]를 누를 때마다 시 +1 (24시간 순환)
//     - HEX 기대값 = 세그먼트 표(Lab 05 hex7seg 표를 상수로 옮김)[t의 각 자리]
//   순서: ① 리셋 → 1초 펄스 172,805개(이틀 + 5초) 동안 매 클럭 비교, 23:59:59 → 00:00:00 두 번
//         ② 설정 모드: 초 정지, 분 +3, 시 +25(= +1), 분 58 → 01 (시 그대로)
//         ③ 설정 해제 후 70초 (분 자리올림 포함)  ④ 동작 중 KEY[0] 리셋 → 00:00:00부터 다시 10초
//   +define+SCH : 회로도 netlist(digital_clock_sch)를 검사한다.
//                 netlist는 FAST_TICK 매크로로 N = 4로 컴파일한 lab12_clockfast_sch 프로젝트에서 만든다.
`timescale 1ns/1ps
module tb_digital_clock;
    localparam N = 4;
    reg        CLOCK_50 = 0;
    reg  [3:0] KEY = 4'b1111;
    reg  [9:0] SW  = 10'b0;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    always #10 CLOCK_50 = ~CLOCK_50;

`ifdef SCH
    digital_clock_sch dut (.CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW),
                           .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));
`else
    digital_clock #(.N(N)) dut (.CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW),
                           .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));
`endif

    // 세그먼트 표 {g,f,e,d,c,b,a}, 0 = 켜짐 (Lab 05 hex7seg, 8.8.7절 표)
    reg [6:0] SEG [0:9];
    initial begin
        SEG[0] = 7'b1000000; SEG[1] = 7'b1111001; SEG[2] = 7'b0100100; SEG[3] = 7'b0110000;
        SEG[4] = 7'b0011001; SEG[5] = 7'b0010010; SEG[6] = 7'b0000010; SEG[7] = 7'b1111000;
        SEG[8] = 7'b0000000; SEG[9] = 7'b0010000;
    end
    function [3:0] digit (input [6:0] s);          // 출력 표시용: 세그먼트 → 숫자 (모르면 15)
        integer d;
        begin digit = 4'hF; for (d = 0; d < 10; d = d + 1) if (SEG[d] == s) digit = d; end
    endfunction

    integer t = 0;              // 기대 시각: 자정부터 지난 초 (0..86399)
    integer e = 0;              // 리셋을 푼 뒤 상승 에지 수
    integer ticks = 0;          // 지금까지 지난 1초 수 (설정 모드 포함)
    integer wraps = 0, errors = 0, checks = 0;
    reg     run = 0;            // 1이면 기대값 갱신
    reg     chk = 0;            // 1이면 매 클럭 비교
    integer hh, mm, ss;

    // 기대값 갱신 (DUT의 내부 신호는 보지 않는다)
    always @(posedge CLOCK_50) if (run) begin
        e = e + 1;
        if (e > 1 && (e - 1) % N == 0) begin
            ticks = ticks + 1;
            if (!SW[0]) begin
                if (t == 86399) wraps = wraps + 1;
                t = (t + 1) % 86400;
            end
        end
    end

    function [41:0] expect_hex (input integer tt);
        integer h, m, s;
        begin
            h = tt / 3600; m = (tt / 60) % 60; s = tt % 60;
            expect_hex = {SEG[h / 10], SEG[h % 10], SEG[m / 10], SEG[m % 10], SEG[s / 10], SEG[s % 10]};
        end
    endfunction
    wire [41:0] hex_all = {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0};

    task compare;
        begin
            checks = checks + 1;
            if (hex_all !== expect_hex(t)) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("   ** mismatch at %0t ns: shows %0d%0d:%0d%0d:%0d%0d expected %02d:%02d:%02d", $time,
                             digit(HEX5), digit(HEX4), digit(HEX3), digit(HEX2), digit(HEX1), digit(HEX0),
                             t / 3600, (t / 60) % 60, t % 60);
            end
        end
    endtask
    always @(negedge CLOCK_50) if (chk) compare;   // 매 클럭(하강 에지)에서 비교

    task show (input [8*14-1:0] tag);
        $display("  %0s | %0d%0d:%0d%0d:%0d%0d | %02d:%02d:%02d", tag,
                 digit(HEX5), digit(HEX4), digit(HEX3), digit(HEX2), digit(HEX1), digit(HEX0),
                 t / 3600, (t / 60) % 60, t % 60);
    endtask

    // 버튼 한 번: 하강 에지에서 누르고 6클럭 뒤 떼고 6클럭 기다린다. 그동안 매 클럭 비교는 쉰다.
    // 누르고 있는 동안 이미 1 증가해 있어야 하고(누른 순간에 동작), 뗄 때는 더 바뀌지 않아야 한다.
    task press (input integer k);       // k = 1: 분, k = 2: 시
        begin
            chk = 0;
            @(negedge CLOCK_50) KEY[k] = 1'b0;
            repeat (6) @(negedge CLOCK_50);
            hh = t / 3600; mm = (t / 60) % 60; ss = t % 60;
            if (k == 1) mm = (mm + 1) % 60; else hh = (hh + 1) % 24;
            t = hh * 3600 + mm * 60 + ss;
            compare;                    // 누르고 있는 동안: 이미 1 증가
            KEY[k] = 1'b1;
            repeat (6) @(negedge CLOCK_50);
            compare;                    // 뗀 뒤: 그대로
            chk = 1;
        end
    endtask

    task wait_ticks (input integer n);  // 1초 n개가 지날 때까지
        integer target;
        begin
            target = ticks + n;
            while (ticks < target) @(negedge CLOCK_50);
        end
    endtask

    integer i;
    initial begin
        $display(" Lab 12 digital clock, N = %0d clocks per second", N);
        $display("  moment         | HEX5..0  | expected");
        // ① 리셋 후 이틀 넘게
        KEY[0] = 0; repeat (3) @(negedge CLOCK_50);
        KEY[0] = 1; run = 1; chk = 1;            // 하강 에지에서 리셋 해제
        @(negedge CLOCK_50); show("after reset   ");
        wait_ticks(86398); show("tick 86398    ");
        wait_ticks(1);     show("tick 86399    ");
        wait_ticks(1);     show("tick 86400    ");
        wait_ticks(1);     show("tick 86401    ");
        wait_ticks(172805 - 86401); show("tick 172805   ");
        $display("  23:59:59 -> 00:00:00 passed %0d times, %0d one-second ticks", wraps, ticks);
        // ② 설정 모드
        @(negedge CLOCK_50) SW[0] = 1;
        wait_ticks(3);     show("set, 3 ticks  ");           // 초가 멈춰 있어야 한다
        for (i = 0; i < 3;  i = i + 1) press(1);  show("min +3        ");
        for (i = 0; i < 25; i = i + 1) press(2);  show("hour +25      ");
        while ((t / 60) % 60 != 58) press(1);     show("min to 58     ");
        for (i = 0; i < 3;  i = i + 1) press(1);  show("min 58 +3     ");   // 59, 00, 01. 시는 그대로
        // ③ 설정 해제
        @(negedge CLOCK_50) SW[0] = 0;
        wait_ticks(70);    show("run 70 s      ");
        // ④ 동작 중 리셋
        chk = 0; run = 0;
        @(negedge CLOCK_50) KEY[0] = 0;
        @(negedge CLOCK_50); @(negedge CLOCK_50);
        t = 0; e = 0;
        compare;                                  // 리셋 중 00:00:00
        KEY[0] = 1; run = 1; chk = 1;
        wait_ticks(10);    show("reset + 10 s  ");
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
