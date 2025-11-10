`timescale 1ns / 1ps
module FullAdder1(x, y, z, S, C);
	input		x, y, z;
	output		S, C;
	
	reg		S, C;
	wire [2:0]	k;
	
	assign k = {x, y, z};
	
	always @ (k)
	begin
		case(k)
			3'b000 : begin
				S <= 1'b0;
				C <= 1'b0;
			end
			3'b001 : begin
				S <= 1'b1;
				C <= 1'b0;
			end	
			3'b010 : begin
				S <= 1'b1;
				C <= 1'b0;
			end
			3'b011 : begin
				S <= 1'b0;
				C <= 1'b1;
			end	
			3'b100 : begin
				S <= 1'b1;
				C <= 1'b0;
			end	
			3'b101 : begin
				S <= 1'b0;
				C <= 1'b1;
			end	
			3'b110 : begin
				S <= 1'b0;
				C <= 1'b1;
			end	
			3'b111 : begin
				S <= 1'b1;
				C <= 1'b1;
			end
		endcase
	end
endmodule
