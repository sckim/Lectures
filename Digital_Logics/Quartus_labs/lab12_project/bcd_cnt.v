// bcd_cnt.v : 한 자리 BCD 카운터, 0..MAX를 센다 (Lab 12, 17장 BCD 카운터, 22.3.3절)
//   MAX = 9 → mod-10 (초·분의 일의 자리),  MAX = 5 → mod-6 (초·분의 십의 자리)
//   en = 1인 클럭에서만 1 증가한다. MAX 다음은 0.
//   co(자리올림) = en이고 지금 값이 MAX일 때 1 → 다음 자리의 en으로 쓴다(조합 출력, 같은 클럭에 함께 바뀐다).
module bcd_cnt #(
    parameter [3:0] MAX = 4'd9
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output reg  [3:0] q,
    output wire       co
);
    assign co = en && (q == MAX);
    always @(posedge clk or negedge rst_n)
        if (!rst_n)  q <= 4'd0;
        else if (en) q <= (q == MAX) ? 4'd0 : q + 4'd1;
endmodule
