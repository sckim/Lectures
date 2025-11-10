`timescale 1ns / 1ps
module FNDDecoderI(clk, key, FND, FNDSel2, FNDSel1);
	input				clk;
	input [15:0]	key;
	output[6:0]		FND;
	output 			FNDSel2, FNDSel1;

	reg [6:0]		FND;
	reg [3:0]		keyVal;

	assign FNDSel2 = 1'b1;
	assign FNDSel1 = 1'b0;
	
	always @(posedge clk) begin
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
			default :;
		endcase

	case(keyVal)
			4'b0000 : FND = 7'b1111110;
			4'b0001 : FND = 7'b0110000;
			4'b0010 : FND = 7'b1101101;
			4'b0011 : FND = 7'b1111001;
			4'b0100 : FND = 7'b0110011;
			4'b0101 : FND = 7'b1011011;
			4'b0110 : FND = 7'b1011111;
			4'b0111 : FND = 7'b1110000;
			4'b1000 : FND = 7'b1111111;
			4'b1001 : FND = 7'b1110011;
			4'b1010 : FND = 7'b1111101;
			4'b1011 : FND = 7'b0011111;
			4'b1100 : FND = 7'b0001101;
			4'b1101 : FND = 7'b0111101;
			4'b1110 : FND = 7'b1101111;
			4'b1111 : FND = 7'b1000111;
		endcase
	end
endmodule