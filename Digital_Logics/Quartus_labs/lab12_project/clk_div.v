// clk_div.v : 50 MHz -> 1 Hz tick 분주기 (Lab 12, 22.3.1절)
//   카운터가 0, 1, ..., N-1을 세고 0으로 돌아가는 클럭에 tick을 1클럭(20 ns) 동안 1로 만든다.
//   tick은 "클럭"이 아니라 "인에이블"이다. 모든 플립플롭은 CLOCK_50 하나로 돈다.
//   N = 50,000,000 → 0..49,999,999를 세는 26비트 카운터 (2^25 < 50,000,000 <= 2^26)
//   시뮬레이션: 테스트벤치에서 clk_div #(.N(4))처럼 N을 줄인다.
//   FAST_TICK 매크로를 정의하면 기본값이 4가 된다(회로도 netlist 검사용 프로젝트 lab12_clockfast_sch).
module clk_div #(
`ifdef FAST_TICK
    parameter N = 4
`else
    parameter N = 50_000_000
`endif
) (
    input  wire clk,      // CLOCK_50
    input  wire rst_n,    // 비동기 리셋, 0이면 리셋 (KEY[0])
    output reg  tick      // N클럭마다 1클럭 동안 1
);
    reg [25:0] cnt;
    always @(posedge clk or negedge rst_n)
        if (!rst_n)          begin cnt <= 26'd0;       tick <= 1'b0; end
        else if (cnt == N-1) begin cnt <= 26'd0;       tick <= 1'b1; end
        else                 begin cnt <= cnt + 26'd1; tick <= 1'b0; end
endmodule
