// tb_mod10.v : 10진(mod-10) 리플 카운터 테스트벤치 (Lab 09 Part C)
// 1) DUT(지연 0) : 누를 때마다 1씩 늘고 9 다음에 0이 되는지 본다. 기대값 = 앞의 값 + 1 (정수 산술)
//    지연이 0이라 정해진 시각에 보면 1010(10)은 보이지 않는다. 다만 같은 시각 안에서 값이 차례로
//    바뀌는 동안(델타 사이클) 1010을 잠깐 거치므로, 그 횟수를 세어 출력만 한다.
//    [주의] 9 → 0 전이는 지연 0 시뮬레이션에서 결과가 하나로 정해지지 않는다. 클리어 때문에 QB가 1 → 0으로
//    떨어지는 것이 셋째 단(QC)에는 하강 에지이기 때문이다. 클리어가 아직 0인 동안 이 에지를 보면 무시되어
//    0000이 되고, 클리어가 먼저 풀린 것으로 처리되면 QC가 토글되어 0100(4)이 된다. 어느 쪽인지는
//    시뮬레이터가 같은 시각의 사건을 처리하는 순서에 달렸다(13.6.3절 [정리자 주] ①의 위험).
//    그래서 이 전이는 0 또는 4를 받아들이고, 어느 쪽이었는지 출력한다(Lab 07의 금지 입력처럼 관찰 항목).
//    그 밖의 전이(0→1 … 8→9, 4→5 …)는 모두 엄격히 비교한다.
// 2) 지연 모델  : 테스트벤치 안의 ripple_mod10_d(플립플롭 2 ns, NAND·AND 1 ns 지연)로 같은 입력을 주고
//    9 → 0 바뀌는 순간의 모든 변화를 시각과 함께 출력한다(13.6.3절 표). 1010이 잠깐 나타나야 한다.
//    지연이 있으면 사건의 순서가 정해지므로 9 다음은 반드시 0이다(엄격히 비교).
// 클럭은 KEY0처럼 준다. clk가 1 → 0으로 바뀌는 순간(누름)이 하강 에지이다.
//   +define+SCH : 1)을 회로도 netlist(ripple_mod10_sch)로 검사
`timescale 1ns/1ps

// 지연이 있는 모델 (13.9절의 글리치 관찰과 같은 방법). 합성용이 아니다.
module tff_neg_d (input wire clk, clrn, output reg q);
    always @(negedge clk or negedge clrn)
        if (!clrn) q <= 1'b0;
        else       q <= #2 ~q;               // 클럭 → 출력 2 ns
endmodule
module ripple_mod10_d (input wire clk, rstn, output wire [3:0] q);
    wire #1 clrn = rstn & ~(q[3] & q[1]);    // NAND + AND 1 ns
    tff_neg_d f0 (.clk(clk),  .clrn(clrn), .q(q[0]));
    tff_neg_d f1 (.clk(q[0]), .clrn(clrn), .q(q[1]));
    tff_neg_d f2 (.clk(q[1]), .clrn(clrn), .q(q[2]));
    tff_neg_d f3 (.clk(q[2]), .clrn(clrn), .q(q[3]));
endmodule

module tb_mod10;
    reg  clk, rstn;
    wire [3:0] q, qd;
    integer k, i, errors, checks, seen10, t10, len10, ed, n0, n4;
    reg  watch;

`ifdef SCH
    ripple_mod10_sch dut (.clk(clk), .rstn(rstn), .q(q));
`else
    ripple_mod10     dut (.clk(clk), .rstn(rstn), .q(q));
`endif
    ripple_mod10_d   dly (.clk(clk), .rstn(rstn), .q(qd));

    task press;
        begin
            #20 clk = 0; #20; k = k + 1;      // 누름 = 하강 에지, 20 ns 뒤에 본다
            checks = checks + 2;
            if (ed == 9) begin                // 9 다음: 0(클리어가 이김) 또는 4(경쟁, 위 [주의])
                if (q === 4'd0)      n0 = n0 + 1;
                else if (q === 4'd4) n4 = n4 + 1;
                else begin errors = errors + 1; $display("   ** dut   k=%0d got %0d after 9", k, q); end
                ed = q;
            end else begin
                ed = ed + 1;
                if (q !== ed) begin errors = errors + 1; $display("   ** dut   k=%0d got %0d expected %0d", k, q, ed); end
            end
            if (qd !== k % 10) begin errors = errors + 1; $display("   ** delay k=%0d got %0d", k, qd); end
            #20 clk = 1;                      // 뗌
        end
    endtask

    always @(q)  if (q === 4'd10) seen10 = seen10 + 1;                     // 델타 사이클에서 10을 거친 횟수
    always @(qd) begin
        if (watch) $display("   %0d ns  qd = %b (%0d)", $time, qd, qd);
        if (qd === 4'd10) t10 = $time;
        else if (t10 >= 0) begin len10 = $time - t10; t10 = -1; end
    end

    initial begin
        errors = 0; checks = 0; k = 0; seen10 = 0; t10 = -1; len10 = 0; watch = 0; ed = 0; n0 = 0; n4 = 0;
        clk = 1; rstn = 1;
        #10 $display(" start : q = %b (unknown)", q);
        rstn = 0; #20; rstn = 1; #20;
        $display(" after rstn : q = %b, delay model = %b", q, qd);
        $display(" press | q (dec)");
        for (i = 1; i <= 25; i = i + 1) begin
            if (i == 10) begin watch = 1; $display(" -- delay model, press 10 (9 -> 0) at %0d ns:", $time + 20); end
            press;
            if (i == 10) watch = 0;
            if (i <= 12) $display("   %2d  | %b (%0d)", i, q, q);
        end
        checks = checks + 1;
        if (len10 == 0 || len10 > 2) begin errors = errors + 1; $display("   ** delay model: 1010 not seen as a short glitch"); end
        $display(" zero-delay DUT : never 1010 at the check times; passed through 1010 %0d times inside one time step", seen10);
        $display(" delay model    : 1010 lasted %0d ns", len10);
        $display(" zero-delay DUT : after 9 came 0 for %0d times, 4 for %0d times", n0, n4);
        // 세는 도중 rstn
        #20 rstn = 0; #20; k = 0; ed = 0; checks = checks + 1; if (q !== 0) errors = errors + 1; rstn = 1; #20;
        for (i = 1; i <= 3; i = i + 1) press;
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
