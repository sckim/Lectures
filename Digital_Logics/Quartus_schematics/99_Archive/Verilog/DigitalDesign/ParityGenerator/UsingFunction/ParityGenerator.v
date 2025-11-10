`timescale 1ns / 1ps
module ParityGenerator(data_in,	parity_out);
	parameter n = 8;
	input[n-1:0]		data_in;
	output[n:0]			parity_out;
	
	function [n:0] parity;
		input[n-1:0]	data;
		begin
			parity =	{^data, data};
		end
	endfunction
	
	assign parity_out = parity(data_in);
endmodule