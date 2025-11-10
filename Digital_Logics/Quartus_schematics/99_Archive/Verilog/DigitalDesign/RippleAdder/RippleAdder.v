`timescale 1ns / 1ps
module RippleAdder(clk, x, y, FND, FNDSel2, FNDSel1);
	input				clk;
	input [3:0]		x, y;
	output [6:0]	FND;
	output 			FNDSel2, FNDSel1;

	reg [6:0]		FND;
	reg 				FNDSel2, FNDSel1;
	wire [3:0]		sum;
	
	wire [3:0]		c;
	reg				clk100Hz;
	reg [6:0]		FNDVal2=7'b0000000, FNDVal1=7'b0000000;
	
	integer 			m=0;

	always @ (posedge (clk)) begin
		if (m >= 4999) begin
			m <= 0;
			clk100Hz <= ~clk100Hz;
		end else
			m <= m+1;
	end		

// referenced by position
	HalfAdder	HA0(x[0], y[0], sum[0], c[0]);
	FullAdder	FA1(x[1], y[1], c[0], sum[1], c[1]);
	FullAdder	FA2(x[2], y[2], c[1], sum[2], c[2]);
	FullAdder	FA3(x[3], y[3], c[2], sum[3], c[3]);
	
	always @(posedge clk)
	begin
		case(sum)
			4'b0000 : FNDVal1 = 7'b1111110;
			4'b0001 : FNDVal1 = 7'b0110000;
			4'b0010 : FNDVal1 = 7'b1101101;
			4'b0011 : FNDVal1 = 7'b1111001;
			4'b0100 : FNDVal1 = 7'b0110011;
			4'b0101 : FNDVal1 = 7'b1011011;
			4'b0110 : FNDVal1 = 7'b1011111;
			4'b0111 : FNDVal1 = 7'b1110000;
			4'b1000 : FNDVal1 = 7'b1111111;
			4'b1001 : FNDVal1 = 7'b1110011;
			4'b1010 : FNDVal1 = 7'b1111101;
			4'b1011 : FNDVal1 = 7'b0011111;
			4'b1100 : FNDVal1 = 7'b0001101;
			4'b1101 : FNDVal1 = 7'b0111101;
			4'b1110 : FNDVal1 = 7'b1101111;
			4'b1111 : FNDVal1 = 7'b1000111;
		endcase

		case(c[3])
			1'b0 : FNDVal2 = 7'b0000000;
			1'b1 : FNDVal2 = 7'b0110000;
		endcase
	end	
		
	always @(clk100Hz, FNDVal2, FNDVal1)
	begin 
		if (clk100Hz) begin
			FNDSel2 = 1'b0;
			FNDSel1 = 1'b1;
			FND = FNDVal2;
		end else begin
			FNDSel2 = 1'b1;
			FNDSel1 = 1'b0;
			FND = FNDVal1;
		end
	end	
endmodule

module FullAdder(fa, fb, fc_in, fsum, fc_out);
	input 			fa, fb, fc_in;
	output			fsum, fc_out;
	
	assign fsum=(~fa&~fb&fc_in)|(~fa&fb&~fc_in)|(fa&~fb&~fc_in)|(fa&fb&fc_in);
	assign fc_out=(fa&fb)|(fa&fc_in)|(fb&fc_in);
endmodule	
	
module HalfAdder(ha, hb, hsum, hc_out);
	input 			ha, hb;
	output			hsum, hc_out;
	
	assign hsum=(~ha&hb)|(ha&~hb);
	assign hc_out=ha&hb;
endmodule
