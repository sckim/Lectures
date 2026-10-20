// cnt24.v : 24진 BCD 카운터 00..23 (Lab 12, 22.3.3절)
//   60진과 달리 20..23에서는 일의 자리가 3까지만 쓰이므로 "23이면 00"을 따로 둔다.
module cnt24 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output reg  [3:0] tens,      // 0..2
    output reg  [3:0] ones       // 0..9 (tens = 2이면 0..3)
);
    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin tens <= 4'd0; ones <= 4'd0; end
        else if (en) begin
            if      (tens == 4'd2 && ones == 4'd3) begin tens <= 4'd0;        ones <= 4'd0; end
            else if (ones == 4'd9)                 begin tens <= tens + 4'd1; ones <= 4'd0; end
            else                                         ones <= ones + 4'd1;
        end
endmodule
