// bcd_counter.v : 동기식 BCD 카운터를 HEX0에 표시 (Lab 09 Part E-2)
//   bcd_counter : 17.10절 코드 그대로. 9 다음 0, 9일 때 자리올림 c = 1
//   seg7hex     : 0–F를 모두 표시하는 7세그먼트 디코더(Lab 05 hex7seg와 같은 글꼴, 0 = 켜짐)
//                 미사용 상태 10–15가 HEX0에 A b C d E F로 보이게 하려고 7447 글꼴 대신 쓴다.
//   bcd_hex     : 보드용 top. KEY0을 클럭으로 쓰는 한 클럭(동기식) 설계

// BCD 카운터와 자리올림 출력
module bcd_counter (input clk, input clrn, output reg [3:0] q, output c);
  assign c = q[3] & q[0];              // 9(1001)일 때 1
  always @(posedge clk or negedge clrn)
    if (!clrn)          q <= 4'd0;
    else if (q == 4'd9) q <= 4'd0;     // 9 다음은 0
    else                q <= q + 4'd1;
endmodule

module seg7hex (
    input  wire [3:0] x,
    output reg  [6:0] seg              // {g, f, e, d, c, b, a}, 0 = 켜짐
);
    always @(*)
        case (x)              //   gfedcba
            4'h0: seg = 7'b1000000;  4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;  4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;  4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;  4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;  4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;  4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;  4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;  default: seg = 7'b0001110;   // F
        endcase
endmodule

module bcd_hex (
    input  wire       CLK,     // KEY[0] 뗄 때 상승 에지 → 1 증가
    input  wire       CLRN,    // KEY[1] 누르면 0
    output wire [6:0] HEX0,
    output wire [3:0] LEDR,    // LEDR[3:0] = q
    output wire       C        // LEDR[9] 자리올림
);
    bcd_counter u_cnt (.clk(CLK), .clrn(CLRN), .q(LEDR), .c(C));
    seg7hex     u_seg (.x(LEDR), .seg(HEX0));
endmodule
