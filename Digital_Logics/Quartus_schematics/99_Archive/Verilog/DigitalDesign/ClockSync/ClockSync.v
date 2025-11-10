`timescale 1ns / 1ps
module ClockSync(clk, a, b, d, k);
	input		clk;
	input		a, b;
	output	d, k;
	
	wire		d;
	reg		k;

	assign d = a & b;

	always @ (posedge clk)
	begin
		k <= a & b;
	end
endmodule