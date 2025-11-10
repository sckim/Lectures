`timescale 1ns / 1ps
module ParityChecker(data_in, parityCheck);
	parameter		n=8;
	input[n:0]		data_in;
	output			parityCheck;
	
	reg				parityCheck;

	task parityTask;
		input [n:0]	in;
		output		out;
		begin
			out = ^in;
		end	
	endtask
	
	always @(data_in) begin
		parityTask(data_in, parityCheck);
	end	
endmodule