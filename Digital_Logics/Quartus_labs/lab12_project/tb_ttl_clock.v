// tb_ttl_clock.v : 7490·7492·7447 디지털 시계 테스트벤치 (Lab 12 Part C)
//   반드시 FAST_TICK을 정의해 컴파일한다:  iverilog -DFAST_TICK ...  /  vlog +define+FAST_TICK ...
//   그러면 Mod50MHz가 4클럭에 한 바퀴를 돌아 Clock_50의 하강 에지 4번 = 1초가 된다.
//   기대값은 시 h, 분 m, 초 s 정수로 따로 계산한다.
//     - 동작(SW[0] = 1): 분주기 리셋을 푼 뒤 하강 에지 수가 4의 배수가 될 때마다 1초
//     - 분 펄스(SW[1]을 1 → 0): m = (m + 1) mod 60, m이 0이 되면 시 펄스도 생긴다(분 십의 자리 QC가 떨어지므로)
//     - 시 펄스(SW[2]를 1 → 0): h = (h + 1) mod 24  (24가 되는 순간 AND 게이트가 두 7490을 클리어)
//     - HEX 기대값 = 7447 글꼴 표(6은 a 없음, 9는 d 없음)
//   순서: ① 처음 표시를 읽어 출발 시각으로 삼고 → 1초 86,470개 동안 매 클럭 비교 (하루가 넘으므로 23:59:59 → 00:00:00을 반드시 지남)
//         ② 정지(SW[0] = 0) 후 SW[1] 3번 → 분 +3, SW[2] 25번 → 시 +1, SW[1] 56번 → 분 00 + 시 +1
//         ③ 다시 동작 10초
//   입력은 Clock_50의 상승 에지에서 바꾸고(카운터는 하강 에지에서 움직임), 출력도 상승 에지에서 비교한다.
//   +define+SCH : 회로도 netlist(ttl_clock_sch, lab12_ttlfast_sch 프로젝트에서 FAST_TICK으로 컴파일)를 검사
`timescale 1ns/1ps
module tb_ttl_clock;
    localparam N = 4;
    reg        Clock_50 = 0;
    reg  [2:0] SW = 3'b000;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    always #10 Clock_50 = ~Clock_50;

`ifdef SCH
    ttl_clock_sch dut (.Clock_50(Clock_50), .SW(SW),
                       .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));
`else
    ttl_clock     dut (.Clock_50(Clock_50), .SW(SW),
                       .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));
`endif

    reg [6:0] SEG [0:9];        // 7447 글꼴 {g,f,e,d,c,b,a}, 0 = 켜짐
    initial begin
        SEG[0] = 7'b1000000; SEG[1] = 7'b1111001; SEG[2] = 7'b0100100; SEG[3] = 7'b0110000;
        SEG[4] = 7'b0011001; SEG[5] = 7'b0010010; SEG[6] = 7'b0000011; SEG[7] = 7'b1111000;
        SEG[8] = 7'b0000000; SEG[9] = 7'b0011000;
    end
    function [3:0] digit (input [6:0] x);
        integer d;
        begin digit = 4'hF; for (d = 0; d < 10; d = d + 1) if (SEG[d] == x) digit = d; end
    endfunction

    integer h = 0, m = 0, s = 0;          // 기대 시각
    integer ne = 0, secs = 0, wraps = 0, errors = 0, checks = 0;
    reg     run = 0, chk = 0;
    wire [41:0] hex_all = {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0};

    task hour_pulse;   begin h = (h + 1) % 24; end endtask
    task minute_pulse; begin m = (m + 1) % 60; if (m == 0) hour_pulse; end endtask
    task second_pulse; begin
        if (h == 23 && m == 59 && s == 59) wraps = wraps + 1;
        s = (s + 1) % 60; if (s == 0) minute_pulse;
    end endtask

    always @(negedge Clock_50) if (run && SW[0]) begin
        ne = ne + 1;
        if (ne % N == 0) begin secs = secs + 1; second_pulse; end
    end

    task compare;
        begin
            checks = checks + 1;
            if (hex_all !== {SEG[h/10], SEG[h%10], SEG[m/10], SEG[m%10], SEG[s/10], SEG[s%10]}) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("   ** mismatch at %0t: shows %0d%0d:%0d%0d:%0d%0d expected %02d:%02d:%02d", $time,
                             digit(HEX5), digit(HEX4), digit(HEX3), digit(HEX2), digit(HEX1), digit(HEX0), h, m, s);
            end
        end
    endtask
    always @(posedge Clock_50) if (chk) compare;

    task show (input [8*14-1:0] tag);
        $display("  %0s | %0d%0d:%0d%0d:%0d%0d | %02d:%02d:%02d", tag,
                 digit(HEX5), digit(HEX4), digit(HEX3), digit(HEX2), digit(HEX1), digit(HEX0), h, m, s);
    endtask
    task wait_secs (input integer n);
        integer target;
        begin target = secs + n; while (secs < target) @(posedge Clock_50); end
    endtask
    // 슬라이드 스위치를 올렸다 내린다 (정지 상태에서). 내리는 순간이 7490 CLKA의 하강 에지
    task toggle (input integer k);
        begin
            chk = 0;
            @(posedge Clock_50) SW[k] = 1'b1;
            repeat (3) @(posedge Clock_50);
            SW[k] = 1'b0;
            repeat (3) @(posedge Clock_50);
            if (k == 1) minute_pulse; else hour_pulse;
            compare;
            chk = 1;
        end
    endtask

    integer i;
    initial begin
`ifndef FAST_TICK
        $display("compile with FAST_TICK (iverilog -DFAST_TICK / vlog +define+FAST_TICK)");
`endif
        $display(" Lab 12 Part C: 7490/7492/7447 clock, %0d falling edges per second", N);
        $display("  moment         | HEX5..0  | expected");
        repeat (3) @(posedge Clock_50);       // 분주기 리셋(SW[0] = 0) 상태
        // 초·분·시 카운터에는 리셋이 없다(7490·7492의 클리어 단자가 GND). 그래서 처음 표시를 읽어
        // 기대값의 출발점으로 삼는다. 보드는 전원을 켜면 레지스터가 0이므로 00:00:00에서 시작한다.
        h = digit(HEX5) * 10 + digit(HEX4); m = digit(HEX3) * 10 + digit(HEX2); s = digit(HEX1) * 10 + digit(HEX0);
        checks = checks + 1;
        if (digit(HEX5) > 2 || digit(HEX4) > 9 || digit(HEX3) > 5 || digit(HEX2) > 9 || digit(HEX1) > 5 || digit(HEX0) > 9
            || h > 23) begin
            errors = errors + 1; h = 0; m = 0; s = 0;
            $display("   ** start display is not a valid time");
        end
        show("start         ");
        @(posedge Clock_50) SW[0] = 1; run = 1; chk = 1;
        wait_secs(1);     show("1 s           ");
        while (!(h == 23 && m == 59 && s == 58)) wait_secs(1);
        show("23:59:58      ");
        wait_secs(1);     show("+1 s          ");
        wait_secs(1);     show("+2 s          ");
        wait_secs(1);     show("+3 s          ");
        while (secs < 86470) wait_secs(1);
        show("86470 s       ");
        $display("  23:59:59 -> 00:00:00 passed %0d times", wraps);
        // ② 정지하고 시각 맞추기. 1초가 지난 직후(q[25] = 0)에 SW[0]을 내린다.
        //    분 펄스는 초 십의 자리 QC = 0(초 00..39)일 때만 OR 게이트를 지나므로 초가 40 미만인지 확인한다.
        @(posedge Clock_50) SW[0] = 0;
        if (s >= 40) $display("   ** seconds >= 40: SW1 pulses would be blocked");
        repeat (4) @(posedge Clock_50); compare; show("stopped       ");
        for (i = 0; i < 3;  i = i + 1) toggle(1);  show("SW1 x3        ");
        for (i = 0; i < 25; i = i + 1) toggle(2);  show("SW2 x25       ");
        for (i = 0; i < 56; i = i + 1) toggle(1);  show("SW1 x56       ");
        // ③ 다시 동작
        @(posedge Clock_50) SW[0] = 1; ne = 0;
        wait_secs(10);    show("run 10 s      ");
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
