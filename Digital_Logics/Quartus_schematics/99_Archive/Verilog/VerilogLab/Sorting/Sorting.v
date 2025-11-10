`timescale 1ns / 1ps
module Sorting(clk, en, a, b, FNDin, FNDout, FNDinSel, FNDoutSel);
	parameter width = 4;
	input [width-1:0]	a, b;
	input clk, en;
	output [6:0] FNDin, FNDout;
	output [1:0] FNDinSel, FNDoutSel;
	
	reg [6:0]	FNDin, FNDout;
	reg [1:0]	FNDinSel, FNDoutSel;
	
	reg			clk100Hz;
	reg [6:0]	FNDin1, FNDin2, FNDout1, FNDout2;
	reg [3:0]	Greater, Less;
	integer		m=0;

	always @ (posedge clk) begin
		if (m >= 4999) begin
			m <= 0;
			clk100Hz <= ~clk100Hz;
		end else
			m <= m+1;
	end		
	
	always @ (posedge clk)
		if(en==1'b0)
			if (a > b) begin
				Greater <= a;
				Less <= b;
			end else begin
				Greater <= b;
				Less <= a;
			end
	
	always @(posedge clk)
	begin
		case(b)
			4'b0000 : FNDin1 = 7'b1111110;
			4'b0001 : FNDin1 = 7'b0110000;
			4'b0010 : FNDin1 = 7'b1101101;
			4'b0011 : FNDin1 = 7'b1111001;
			4'b0100 : FNDin1 = 7'b0110011;
			4'b0101 : FNDin1 = 7'b1011011;
			4'b0110 : FNDin1 = 7'b1011111;
			4'b0111 : FNDin1 = 7'b1110000;
			4'b1000 : FNDin1 = 7'b1111111;
			4'b1001 : FNDin1 = 7'b1110011;
			4'b1010 : FNDin1 = 7'b1111101;
			4'b1011 : FNDin1 = 7'b0011111;
			4'b1100 : FNDin1 = 7'b0001101;
			4'b1101 : FNDin1 = 7'b0111101;
			4'b1110 : FNDin1 = 7'b1101111;
			4'b1111 : FNDin1 = 7'b1000111;
		endcase

		case(a)
			4'b0000 : FNDin2 = 7'b1111110;
			4'b0001 : FNDin2 = 7'b0110000;
			4'b0010 : FNDin2 = 7'b1101101;
			4'b0011 : FNDin2 = 7'b1111001;
			4'b0100 : FNDin2 = 7'b0110011;
			4'b0101 : FNDin2 = 7'b1011011;
			4'b0110 : FNDin2 = 7'b1011111;
			4'b0111 : FNDin2 = 7'b1110000;
			4'b1000 : FNDin2 = 7'b1111111;
			4'b1001 : FNDin2 = 7'b1110011;
			4'b1010 : FNDin2 = 7'b1111101;
			4'b1011 : FNDin2 = 7'b0011111;
			4'b1100 : FNDin2 = 7'b0001101;
			4'b1101 : FNDin2 = 7'b0111101;
			4'b1110 : FNDin2 = 7'b1101111;
			4'b1111 : FNDin2 = 7'b1000111;
		endcase

		case(Less)
			4'b0000 : FNDout1 = 7'b1111110;
			4'b0001 : FNDout1 = 7'b0110000;
			4'b0010 : FNDout1 = 7'b1101101;
			4'b0011 : FNDout1 = 7'b1111001;
			4'b0100 : FNDout1 = 7'b0110011;
			4'b0101 : FNDout1 = 7'b1011011;
			4'b0110 : FNDout1 = 7'b1011111;
			4'b0111 : FNDout1 = 7'b1110000;
			4'b1000 : FNDout1 = 7'b1111111;
			4'b1001 : FNDout1 = 7'b1110011;
			4'b1010 : FNDout1 = 7'b1111101;
			4'b1011 : FNDout1 = 7'b0011111;
			4'b1100 : FNDout1 = 7'b0001101;
			4'b1101 : FNDout1 = 7'b0111101;
			4'b1110 : FNDout1 = 7'b1101111;
			4'b1111 : FNDout1 = 7'b1000111;
		endcase

		case(Greater)
			4'b0000 : FNDout2 = 7'b1111110;
			4'b0001 : FNDout2 = 7'b0110000;
			4'b0010 : FNDout2 = 7'b1101101;
			4'b0011 : FNDout2 = 7'b1111001;
			4'b0100 : FNDout2 = 7'b0110011;
			4'b0101 : FNDout2 = 7'b1011011;
			4'b0110 : FNDout2 = 7'b1011111;
			4'b0111 : FNDout2 = 7'b1110000;
			4'b1000 : FNDout2 = 7'b1111111;
			4'b1001 : FNDout2 = 7'b1110011;
			4'b1010 : FNDout2 = 7'b1111101;
			4'b1011 : FNDout2 = 7'b0011111;
			4'b1100 : FNDout2 = 7'b0001101;
			4'b1101 : FNDout2 = 7'b0111101;
			4'b1110 : FNDout2 = 7'b1101111;
			4'b1111 : FNDout2 = 7'b1000111;
		endcase
	end	

	always @(clk100Hz, FNDin1, FNDin2, FNDout1, FNDout2)
	begin 
		if (clk100Hz) begin
			FNDinSel[0] = 1'b0;
			FNDinSel[1] = 1'b1;
			FNDin = FNDin1;
			
			FNDoutSel[0] = 1'b0;
			FNDoutSel[1] = 1'b1;
			FNDout = FNDout1;
		end else begin
			FNDinSel[0] = 1'b1;
			FNDinSel[1] = 1'b0;
			FNDin = FNDin2;

			FNDoutSel[0] = 1'b1;
			FNDoutSel[1] = 1'b0;
			FNDout = FNDout2;
		end
	end	
endmodule
