`timescale 1ns / 1ps
module FNDDecoderII(clk, a, b, FND, FNDSel2, FNDSel1);
	input				clk;
	input [3:0]		a, b;
	output[6:0]		FND;
	output 			FNDSel2, FNDSel1;

	reg [6:0]		FND;
	reg 				FNDSel2, FNDSel1;
	
	reg				clk100Hz;
	reg [6:0]		FNDa, FNDb;
	integer			m=0;

	always @ (posedge clk) begin
		if (m >= 4999) begin
			m <= 0;
			clk100Hz <= ~clk100Hz;
		end else
			m <= m+1;
	end		

	always @(posedge clk) begin
		case(a)
			4'b0000 : FNDa = 7'b1111110;
			4'b0001 : FNDa = 7'b0110000;
			4'b0010 : FNDa = 7'b1101101;
			4'b0011 : FNDa = 7'b1111001;
			4'b0100 : FNDa = 7'b0110011;
			4'b0101 : FNDa = 7'b1011011;
			4'b0110 : FNDa = 7'b1011111;
			4'b0111 : FNDa = 7'b1110000;
			4'b1000 : FNDa = 7'b1111111;
			4'b1001 : FNDa = 7'b1110011;
			4'b1010 : FNDa = 7'b1111101;
			4'b1011 : FNDa = 7'b0011111;
			4'b1100 : FNDa = 7'b0001101;
			4'b1101 : FNDa = 7'b0111101;
			4'b1110 : FNDa = 7'b1101111;
			4'b1111 : FNDa = 7'b1000111;
		endcase

		case(b)
			4'b0000 : FNDb = 7'b1111110;
			4'b0001 : FNDb = 7'b0110000;
			4'b0010 : FNDb = 7'b1101101;
			4'b0011 : FNDb = 7'b1111001;
			4'b0100 : FNDb = 7'b0110011;
			4'b0101 : FNDb = 7'b1011011;
			4'b0110 : FNDb = 7'b1011111;
			4'b0111 : FNDb = 7'b1110000;
			4'b1000 : FNDb = 7'b1111111;
			4'b1001 : FNDb = 7'b1110011;
			4'b1010 : FNDb = 7'b1111101;
			4'b1011 : FNDb = 7'b0011111;
			4'b1100 : FNDb = 7'b0001101;
			4'b1101 : FNDb = 7'b0111101;
			4'b1110 : FNDb = 7'b1101111;
			4'b1111 : FNDb = 7'b1000111;
		endcase
	end
	
	always @(clk100Hz, FNDa, FNDb)
	begin 
		if (clk100Hz) begin
			FNDSel1 = 1'b0;
			FNDSel2 = 1'b1;
			FND = FNDb;
		end else begin
			FNDSel1 = 1'b1;
			FNDSel2 = 1'b0;
			FND = FNDa;
		end
	end	
endmodule