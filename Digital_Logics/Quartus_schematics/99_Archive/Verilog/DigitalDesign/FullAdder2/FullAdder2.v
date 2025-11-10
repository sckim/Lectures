`timescale 1ns / 1ps
module FullAdder2(x, y, z, S, C);
	input			x, y, z;
	output		S, C;
		
	assign S = (~x&~y&z)|(~x&y&~z)|(x&~y&~z)|(x&y&z);
	assign C = (x&y)|(x&z)|(y&z);
endmodule
