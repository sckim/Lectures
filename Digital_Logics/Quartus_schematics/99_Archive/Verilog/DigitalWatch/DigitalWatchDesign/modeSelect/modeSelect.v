`timescale 1ns / 1ps
module modeSelect(reset, sw0, mode_out);
	input				reset;
	input				sw0;
	output [1:0]	mode_out;
	
	reg [1:0]		mode=2'b00;
	
	always @ (posedge (sw0) or negedge reset) begin
		if (~reset)
			mode <= 2'b00;
		else
			mode <= mode + 1'b1;
	end
	assign mode_out = mode;
	endmodule