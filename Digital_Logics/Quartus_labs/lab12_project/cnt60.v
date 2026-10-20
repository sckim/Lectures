// cnt60.v : 60진 BCD 카운터 = mod-10(일의 자리) + mod-6(십의 자리) (Lab 12, 22.3.3절)
//   22장의 cnt60(always 하나로 쓴 것)과 동작이 같다. 여기서는 18.7.3절의 권고대로
//   10진과 6진 블록(bcd_cnt)을 이어 만들었다.
//   co = en && tens == 5 && ones == 9  (59에서 증가하는 순간 1)
module cnt60 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,        // 이번 클럭에 1 증가
    output wire [3:0] tens,      // 십의 자리 0..5
    output wire [3:0] ones,      // 일의 자리 0..9
    output wire       co         // 59 → 00 이 되는 클럭에 1
);
    wire c1;                     // 일의 자리 자리올림 (9 → 0)
    bcd_cnt #(.MAX(4'd9)) u_ones (.clk(clk), .rst_n(rst_n), .en(en), .q(ones), .co(c1));
    bcd_cnt #(.MAX(4'd5)) u_tens (.clk(clk), .rst_n(rst_n), .en(c1), .q(tens), .co(co));
endmodule
