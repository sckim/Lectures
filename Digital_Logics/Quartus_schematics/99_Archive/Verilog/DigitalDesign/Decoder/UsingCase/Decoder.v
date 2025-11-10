`timescale 1ns / 1ps
module Decoder(x, D,	en);
	input [2:0]		x;
	input				en;
	output [7:0]	D;
	
	reg [7:0]		D;
	
	always @(en or x)
	begin
		D = 8'h00;
		if(en) begin
			case(x)
				3'h0 : D = 8'h01;
				3'h1 : D = 8'h02;
				3'h2 : D = 8'h04;
				3'h3 : D = 8'h08;
				3'h4 : D = 8'h10;
				3'h5 : D = 8'h20;
				3'h6 : D = 8'h40;
				3'h7 : D = 8'h80;
			endcase
		end
	end	
endmodule