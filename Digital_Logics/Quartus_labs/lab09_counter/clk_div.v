// clk_div.v : 1클럭 폭 tick을 만드는 분주기 (22장 22.3.1절 코드 그대로)
//   N클럭마다 1클럭 동안 tick = 1.  N = 50,000,000이면 1초에 한 번 20 ns 펄스.
//   tick은 클럭이 아니라 인에이블로 쓴다. 모든 플립플롭이 CLOCK_50 하나로 돈다.
module clk_div #(parameter N = 50_000_000) (   // N: 분주비
    input  wire clk, rst_n,
    output reg  tick                            // N클럭마다 1클럭 동안 1
);
    reg [25:0] cnt;
    always @(posedge clk or negedge rst_n)
        if (!rst_n)          begin cnt <= 0;       tick <= 1'b0; end
        else if (cnt == N-1) begin cnt <= 0;       tick <= 1'b1; end
        else                 begin cnt <= cnt + 1; tick <= 1'b0; end
endmodule
