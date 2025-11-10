`timescale 1ns / 1ps
module SimpleGates(a, b, c, d, y);
        input	a, b, c, d;
        output y;
        assign y=~(a|b) & ~(c&d);
endmodule