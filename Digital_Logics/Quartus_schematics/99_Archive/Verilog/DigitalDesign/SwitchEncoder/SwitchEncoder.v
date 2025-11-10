`timescale 1ns / 1ps
module SwitchEncoder(clk, key, keyVal);
	input				clk;
	input [15:0]	key;
	output [3:0]	keyVal;

	reg [3:0]		keyVal;
	
	always @(posedge clk)
	begin
		case(key)
			16'b0000000000000001 : keyVal = 4'b0000;
			16'b0000000000000010 : keyVal = 4'b0001;
			16'b0000000000000100 : keyVal = 4'b0010;
			16'b0000000000001000 : keyVal = 4'b0011;
			16'b0000000000010000 : keyVal = 4'b0100;
			16'b0000000000100000 : keyVal = 4'b0101;
			16'b0000000001000000 : keyVal = 4'b0110;
			16'b0000000010000000 : keyVal = 4'b0111;
			16'b0000000100000000 : keyVal = 4'b1000;
			16'b0000001000000000 : keyVal = 4'b1001;
			16'b0000010000000000 : keyVal = 4'b1010;
			16'b0000100000000000 : keyVal = 4'b1011;
			16'b0001000000000000 : keyVal = 4'b1100;
			16'b0010000000000000 : keyVal = 4'b1101;
			16'b0100000000000000 : keyVal = 4'b1110;
			16'b1000000000000000 : keyVal = 4'b1111;
			default	 				:;
		endcase
	end
endmodule
