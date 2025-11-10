`timescale 1ns / 1ps
module ParityGenerator(data_in,	parity_out);
	input[7:0]			data_in;
	output[8:0]			parity_out;
	
	assign	parity_out = {^data_in, data_in};
endmodule