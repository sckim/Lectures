// clkdiv.v : 분주기 50 MHz → 1 Hz, 듀티비 50% (18.10절 코드)
//   HALF클럭마다 출력을 뒤집는다. 출력 한 주기 = 2 × HALF클럭.  50,000,000 / (2 × 25,000,000) = 1 Hz
//   시뮬레이션에서는 인스턴스 파라미터로 줄인다: clkdiv #(.HALF(3)) u (...)
// [정리자 주] 18.10절 코드에 전원 투입 값(선언의 = 0)만 더했다. Lab 09 Part E의 회로도는 rst를 GND에 묶어
//   리셋 없이 쓰므로, 초기값이 없으면 시뮬레이션에서 cnt와 clk1이 끝까지 x이다.
//   Quartus는 이 초기값을 레지스터의 전원 투입 값으로 쓴다.
module clkdiv #(parameter HALF = 25_000_000)
  (input clk50, input rst, output reg clk1 = 1'b0);   // = 1'b0 : [정리자 주] 전원 투입 값
  reg [24:0] cnt = 25'd0;             // 0–24,999,999를 세는 25비트
  always @(posedge clk50)
    if (rst) begin cnt <= 0; clk1 <= 0; end
    else if (cnt == HALF - 1) begin cnt <= 0; clk1 <= ~clk1; end
    else cnt <= cnt + 1'b1;
endmodule
