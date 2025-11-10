`timescale 1ns / 1ps
module BCDAdder(clk, a, b, FND, FNDSel1, FNDSel2);
	parameter 				width=4;
	input						clk;
	input [width-1:0]		a, b;
	output [6:0]			FND;
	output					FNDSel1, FNDSel2;
	
	reg [6:0]				FND;
	reg						FNDSel1, FNDSel2;

	reg [6:0]				FNDVal1, FNDVal2;
	reg						c;
	reg						clk100Hz;
	
	integer					mid_sum=0;
	integer					sum=0;
	integer					k=0;

	always @ (posedge (clk)) begin
		if (k >= 4999) begin
			k <= 0;
			clk100Hz <= ~clk100Hz;
		end else
			k <= k+1;
	end		

	always @(a or b or mid_sum)
	begin
		mid_sum = a+b;
		if (mid_sum < 10) begin
			c = 0;
			sum = mid_sum;
		end else begin
			c = 1;
			sum = mid_sum%10;
		end	
	end		
	
	always @(sum or c)
	begin
		case(sum)
			0 : FNDVal1 = 7'b1111110;
			1 : FNDVal1 = 7'b0110000;
			2 : FNDVal1 = 7'b1101101;
			3 : FNDVal1 = 7'b1111001;
			4 : FNDVal1 = 7'b0110011;
			5 : FNDVal1 = 7'b1011011;
			6 : FNDVal1 = 7'b1011111;
			7 : FNDVal1 = 7'b1110000;
			8 : FNDVal1 = 7'b1111111;
			9 : FNDVal1 = 7'b1110011;
			default : FNDVal1 = 7'b00000000;	
		endcase
		case(c)
			0 : FNDVal2 = 7'b1111110;
			1 : FNDVal2 = 7'b0110000;
			default : FNDVal2 = 7'b00000000;	
		endcase
	end
	
	always @(clk100Hz, FNDVal1, FNDVal2)
	begin
		if (clk100Hz) begin
			FNDSel1 = 1'b0;
			FNDSel2 = 1'b1;
			FND = FNDVal1;
		end else begin
			FNDSel1 = 1'b1;
			FNDSel2 = 1'b0;
			FND = FNDVal2;
		end
	end	
endmodule