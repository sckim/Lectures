`timescale 1ns / 1ps
module FullSubtractor(Xi, Yi, Bi, Di, B);
	input			Xi, Yi, Bi;
	output		Di, B;
	
	reg Di, B;
	
	integer diff;
	
	always @(Xi or Yi or Bi or diff)
	begin
		diff <= Xi - Yi - Bi;
		if (diff == -2) begin
			Di <= 1'b0;
			B <= 1'b1;
		end else if (diff == -1) begin
			Di <= 1'b1;
			B <= 1'b1;
		end else if (diff == 0) begin
			Di <= 1'b0;
			B <= 1'b0;
		end else begin
			Di <= 1'b1;
			B <= 1'b0;
		end
	end	
endmodule

