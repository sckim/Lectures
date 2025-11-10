`timescale 1ns / 1ps
module FullAdder3(x, y,	z,	S, C);
	input			x, y, z;
	output		S, C;
	
	reg S, C;
	
	always @(x or y or z)
		{C, S} = x+y+z;
endmodule
