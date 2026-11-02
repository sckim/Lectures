// Mod-50,000,000 up-counter
// q counts 0 .. 49,999,999 on each falling edge of n_cp, so with the
// 50 MHz board clock q[25] repeats once per second (about 1 Hz).
module Mod50MHz (
    input             n_cp,   // clock, counts on the falling edge
    input             n_rd,   // asynchronous reset, active low
    output reg [25:0] q
);

    always @(negedge n_cp or negedge n_rd) begin
        if (!n_rd)
            q <= 26'd0;
        else if (q == 26'd49_999_999)
            q <= 26'd0;
        else
            q <= q + 26'd1;
    end

endmodule
