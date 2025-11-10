`timescale 1ns / 1ps
module Comparator(a, b, aLessb, aGreaterb, aEqualb);
	parameter width = 4;
	input [width-1:0]	a, b;
	output	aLessb, aGreaterb, aEqualb;
	
	reg	aLessb, aGreaterb, aEqualb;

	always @ (a or b)
	begin
		if (a > b) begin
			aLessb <= 1'b0;
			aEqualb <= 1'b0;
			aGreaterb <= 1'b1;
		end else if	(a == b) begin
			aLessb <= 1'b0;
			aEqualb <= 1'b1;
			aGreaterb <= 1'b0;
		end else begin
			aLessb <= 1'b1;
			aEqualb <= 1'b0;
			aGreaterb <= 1'b0;
		end
	end
endmodule