// tb_btn_edge.v : 버튼 에지 검출 테스트벤치 (Lab 12 Part A, 22.3.5절)
//   KEY를 길이가 다른 다섯 번(1, 2, 7, 30, 3클럭) 누른다. 기대값:
//   (1) 누를 때마다 pulse가 정확히 한 번, 1클럭 폭으로 나온다
//   (2) pulse는 KEY가 0이 된 뒤 두 번째 상승 에지가 지나기 전 한 클럭 동안만 1이다
//       (d1이 0을 받은 에지 ~ d2가 0을 받는 에지 사이)
//   (3) 버튼을 떼는 순간(0 → 1)에는 pulse가 나오지 않는다
`timescale 1ns/1ps
module tb_btn_edge;
    reg clk = 0, key_n = 1;
    always #10 clk = ~clk;
    wire pulse;
    btn_edge dut (.clk(clk), .key_n(key_n), .pulse(pulse));
    integer i, j, errors = 0, checks = 0, pulses = 0, width, at;
    integer len [0:4];
    initial begin
        len[0] = 1; len[1] = 2; len[2] = 7; len[3] = 30; len[4] = 3;
        repeat (3) @(negedge clk);             // d1, d2가 1로 채워질 때까지
        $display(" press | held clocks | pulses | width | pulse at clock no.");
        for (i = 0; i < 5; i = i + 1) begin
            key_n = 0;                         // 하강 에지에서 누른다
            width = 0; j = 0; at = 0;
            repeat (len[i] + 6) begin          // 누르고 있는 동안 + 뗀 뒤 몇 클럭
                @(negedge clk); j = j + 1;
                if (j == len[i]) key_n = 1;    // len 클럭 뒤 뗀다
                checks = checks + 1;
                if (pulse !== (j == 1)) errors = errors + 1;   // 첫 상승 에지 뒤 한 클럭만 1
                width = width + pulse;
                if (pulse === 1'b1) at = j;
            end
            pulses = pulses + (width > 0);
            $display("   %0d   |     %2d      |   %0d    |   %0d   |  %0d", i + 1, len[i], (width > 0), width, at);
        end
        checks = checks + 1;
        if (pulses !== 5) errors = errors + 1;
        $display(" total pulses for 5 presses: %0d", pulses);
        if (errors == 0) $display("RESULT: PASS (%0d/%0d)", checks, checks);
        else             $display("RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
