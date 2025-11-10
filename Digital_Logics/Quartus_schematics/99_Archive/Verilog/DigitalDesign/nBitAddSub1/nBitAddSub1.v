`timescale 1ns / 1ps
module nBitAddSub1(a, b, m, sum);
	parameter width=4;
	input [width-1:0]	a, b;
	input					m;
	output [width+1:0] 	sum;

	reg [width+1:0]		sum;
	
	always @(a or b or m)
	begin
		if (m==1'b0)
			sum = a+b;
		else
			sum = a-b;
	end	
endmodule