`timescale 1ns / 1ps
module RegisterInference(clk, clr, pre, load, data, d, q1, q2);
	input		clk, clr, pre, load, data, d;
	output	q1, q2;
	reg		q1, q2;

	always @(posedge clk or posedge load)
		if (load)
			q1 <= data;
		else
			q1 <= d;
		
	always @(posedge clk or negedge clr or negedge pre)
		if (!clr)
			q2 <= 1'b0;
		else if (!pre)
			q2 <= 1'b1;
		else
			q2 <= d;
endmodule