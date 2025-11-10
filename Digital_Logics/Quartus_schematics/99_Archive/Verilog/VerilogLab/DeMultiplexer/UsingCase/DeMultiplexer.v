`timescale 1ns / 1ps
module DeMultiplexer(s, i, y);
	input[1:0]		s;
	input				i;
	output[3:0]		y;
	
	reg[3:0]			y;
	
	always @ (s or i)
	begin
		case(s)
			2'b00 : y = {1'bz, 1'bz, 1'bz, i};
			2'b01 : y = {1'bz, 1'bz, i, 1'bz};
			2'b10 : y = {1'bz, i, 1'bz, 1'bz};
			2'b11 : y = {i, 1'bz, 1'bz, 1'bz};
		endcase
	end
endmodule