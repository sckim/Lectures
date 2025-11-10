`timescale 1ns / 1ps
module Decoder(x, D,	en);
	input[2:0]		x;
	input				en;
	output[7:0]		D;
	
	assign D = (en) ? 1'b1 << x : 8'h00;
endmodule