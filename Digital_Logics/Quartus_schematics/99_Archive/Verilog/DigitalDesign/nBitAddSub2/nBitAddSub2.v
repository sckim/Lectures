`timescale 1ns / 1ps
module nBitAddSub2(clk, a, b, m, FND2, FND1, FND2Sel, FND1Sel);
	parameter 				width=4;
	input						clk;
	input [width-1:0]		a, b;
	input						m;
	output [6:0]			FND2, FND1;
	output [1:0]			FND2Sel;
	output [1:0]			FND1Sel;
	
	reg [6:0]				FND2, FND1;
	reg [1:0]				FND1Sel;
	integer 					ai=0, bi=0;
	integer					hex1=0, hex2=0;
	reg						sign;
	
	reg [6:0]				FND1Val2, FND1Val1;
	reg						clk100Hz;
	
	integer					result;
	integer					k=0;

	always @ (posedge (clk)) begin
		if (k >= 4999) begin
			k <= 0;
			clk100Hz <= ~clk100Hz;
		end else
			k <= k+1;
	end		

	always @(a or b or m or result)
	begin
		ai = a;
		bi = b;
		if (m==1'b0) 
			result = ai+bi;
		else
			result = ai-bi;
		
		if (result < 0) begin
			sign = 1'b1;
			hex2 = -result / 16;
			hex1 = -result % 16;
		end else begin
			sign = 1'b0;
			hex2 = result / 16;
			hex1 = result % 16;
		end
	end		
	
	always @(hex2 or hex1)
	begin
		case(hex2)
			0 : FND1Val2 = 7'b1111110;
			1 : FND1Val2 = 7'b0110000;
			2 : FND1Val2 = 7'b1101101;
			3 : FND1Val2 = 7'b1111001;
			4 : FND1Val2 = 7'b0110011;
			5 : FND1Val2 = 7'b1011011;
			6 : FND1Val2 = 7'b1011111;
			7 : FND1Val2 = 7'b1110000;
			8 : FND1Val2 = 7'b1111111;
			9 : FND1Val2 = 7'b1110011;
			10 : FND1Val2 = 7'b1111101;
			11 : FND1Val2 = 7'b0011111;
			12 : FND1Val2 = 7'b0001101;
			13 : FND1Val2 = 7'b0111101;
			14 : FND1Val2 = 7'b1101111;
			15 : FND1Val2 = 7'b1000111;
			default : FND1Val2 = 7'b0000000;
		endcase
		case(hex1)
			0 : FND1Val1 = 7'b1111110;
			1 : FND1Val1 = 7'b0110000;
			2 : FND1Val1 = 7'b1101101;
			3 : FND1Val1 = 7'b1111001;
			4 : FND1Val1 = 7'b0110011;
			5 : FND1Val1 = 7'b1011011;
			6 : FND1Val1 = 7'b1011111;
			7 : FND1Val1 = 7'b1110000;
			8 : FND1Val1 = 7'b1111111;
			9 : FND1Val1 = 7'b1110011;
			10 : FND1Val1 = 7'b1111101;
			11 : FND1Val1 = 7'b0011111;
			12 : FND1Val1 = 7'b0001101;
			13 : FND1Val1 = 7'b0111101;
			14 : FND1Val1 = 7'b1101111;
			15 : FND1Val1 = 7'b1000111;
			default : FND1Val1 = 7'b0000000;
		endcase
	end
	
	assign FND2Sel[1] = 1'b1;
	assign FND2Sel[0] = 1'b0;

	always @(sign)
	begin
		if (sign == 1'b1)
			FND2 = 7'b0000001;
		else
			FND2 = 7'b0000000;
	end	
	
	always @(clk100Hz, FND1Val2, FND1Val1)
	begin 
		if (clk100Hz) begin
			FND1Sel[0] = 1'b0;
			FND1Sel[1] = 1'b1;
			FND1 = FND1Val1;
		end else begin
			FND1Sel[0] = 1'b1;
			FND1Sel[1] = 1'b0;
			FND1 = FND1Val2;
		end
	end	
endmodule