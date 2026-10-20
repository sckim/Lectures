// hex7seg.v : 4-bit value -> 7-segment pattern for one DE1-SoC HEX digit (Lab 05 Part B)
//   DE1-SoC HEX0..HEX5 are COMMON ANODE: a segment is ON when its pin is 0 (active-low).
//   HEX0[6:0] = {g, f, e, d, c, b, a}  (HEX0[0] = a)
//   Font = 8.8.7 table: 6 and 9 with tails, A b C d E F for 10..15.
module hex7seg (
    input  wire [3:0] SW,      // SW[3:0] = 표시할 값 (SW[3]이 MSB)
    output reg  [6:0] HEX0     // 0 = 세그먼트 켜짐
);
    always @(*) begin
        case (SW)            //   gfedcba      켜지는 세그먼트
            4'h0: HEX0 = 7'b1000000;   // a b c d e f
            4'h1: HEX0 = 7'b1111001;   // b c
            4'h2: HEX0 = 7'b0100100;   // a b d e g
            4'h3: HEX0 = 7'b0110000;   // a b c d g
            4'h4: HEX0 = 7'b0011001;   // b c f g
            4'h5: HEX0 = 7'b0010010;   // a c d f g
            4'h6: HEX0 = 7'b0000010;   // a c d e f g   (꼬리 있는 6)
            4'h7: HEX0 = 7'b1111000;   // a b c
            4'h8: HEX0 = 7'b0000000;   // a b c d e f g
            4'h9: HEX0 = 7'b0010000;   // a b c d f g   (꼬리 있는 9)
            4'hA: HEX0 = 7'b0001000;   // a b c e f g   A
            4'hB: HEX0 = 7'b0000011;   // c d e f g     b
            4'hC: HEX0 = 7'b1000110;   // a d e f       C
            4'hD: HEX0 = 7'b0100001;   // b c d e g     d
            4'hE: HEX0 = 7'b0000110;   // a d e f g     E
            4'hF: HEX0 = 7'b0001110;   // a e f g       F
            default: HEX0 = 7'b1111111; // 모두 꺼짐
        endcase
    end
endmodule
