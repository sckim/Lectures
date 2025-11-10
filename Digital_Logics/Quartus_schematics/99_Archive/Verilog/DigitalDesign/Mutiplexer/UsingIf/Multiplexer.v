`timescale 1ns / 1ps
module Multiplexer(s, i, y);				
	input[1:0]	s;
	input[3:0]	i;
	output		y;
	
	reg			y;
	
	always @ (s or i)
	begin : MUX
		if (s == 2'b00) begin
			y = i[0];
		end else if (s == 2'b01) begin
			y = i[1];
		end else if (s == 2'b10) begin
			y = i[2];
		end else begin
			y = i[3];
		end
	end
endmodule