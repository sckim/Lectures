`timescale 1ns / 1ps
module CarryLookAheadAdder(clk, x, y, FND, FNDSel2, FNDSel1);
	input				clk;
	input [3:0]		x, y;
	output[6:0]		FND;
	output			FNDSel2, FNDSel1;

	reg [6:0]		FND;
	reg				FNDSel2, FNDSel1;
	
	
	wire [3:0]		p, g;
	wire [3:0]		sum;
	wire [4:1]		c;
	
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
	Middle			M3(x[3], y[3], p[3], g[3]);
	Middle			M2(x[2], y[2], p[2], g[2]);
	Middle			M1(x[1], y[1], p[1], g[1]);
	Middle			M0(x[0], y[0], p[0], g[0]);
	CarryAheadGen	CA(p[3:0], g[3:0], c[4:1]);
	XOR_2				X3(p[3], c[3], sum[3]);			
	XOR_2				X2(p[2], c[2], sum[2]);			
	XOR_2				X1(p[1], c[1], sum[1]);			
	XOR_2				X0(p[0], 1'b0, sum[0]);
	
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

		case(c[4])
			1'b0 : FNDVal2 = 7'b1111110;
			1'b1 : FNDVal2 = 7'b0110000;
		endcase
	end	
		
	always @(clk100Hz, FNDVal1, FNDVal2)
	begin 
		if (clk100Hz) begin
			FNDSel1 = 1'b1;
			FNDSel2 = 1'b0;
			FND = FNDVal2;
		end else begin
			FNDSel1 = 1'b0;
			FNDSel2 = 1'b1;
			FND = FNDVal1;
		end
	end	
endmodule

module CarryAheadGen(p, g, c);
	input [3:0]		p, g;
	output [4:1]	c;
	
	assign c[1]=g[0];
	assign c[2]=g[1]|(p[1]&g[0]);
	assign c[3]=g[2]|(p[2]&g[1])|(p[2]&p[1]&g[0]);
	assign c[4]=g[3]|(p[3]&g[2])|(p[3]&p[2]&g[1])|(p[3]&p[2]&p[1]&g[0]);
endmodule	
	
module XOR_2(p, c, s);
	input 		p, c;
	output		s;
	
	assign s=p^c;
endmodule	

module Middle(a, b, p, g);
	input 		a, b;
	output 		p, g;
	
	assign p=a^b;
	assign g=a&b;
endmodule