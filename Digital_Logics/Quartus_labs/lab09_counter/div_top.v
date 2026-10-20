// div_top.v : 분주기 두 가지를 LED로 보는 보드용 top (Lab 09 Part A)
//   LEDR[0]   = clkdiv 출력. 0.5초 켜짐, 0.5초 꺼짐 (1 Hz 구형파, 18.6.2절 방법 ①)
//   LEDR[4:1] = clk_div의 1초 tick을 인에이블로 쓴 4비트 카운터 (22.3.1절 방식)
//               LEDR[1]은 2초, LEDR[2]는 4초, LEDR[3]은 8초, LEDR[4]는 16초 주기 (18.6.1절 "카운터는 분주기")
//   모든 플립플롭의 클럭은 CLOCK_50 하나이다.
module div_top #(parameter HALF = 25_000_000, parameter N = 50_000_000) (
    input  wire       CLOCK_50,   // PIN_AF14
    input  wire       rst_n,      // KEY[0] 누르는 동안 리셋
    output wire [4:0] LEDR
);
    wire       tick;
    reg  [3:0] cnt;
    clkdiv  #(.HALF(HALF)) u_sq (.clk50(CLOCK_50), .rst(~rst_n), .clk1(LEDR[0]));
    clk_div #(.N(N))       u_tk (.clk(CLOCK_50), .rst_n(rst_n), .tick(tick));
    always @(posedge CLOCK_50 or negedge rst_n)
        if (!rst_n)     cnt <= 4'd0;
        else if (tick)  cnt <= cnt + 4'd1;     // 1초에 한 번만 1 증가
    assign LEDR[4:1] = cnt;
endmodule
