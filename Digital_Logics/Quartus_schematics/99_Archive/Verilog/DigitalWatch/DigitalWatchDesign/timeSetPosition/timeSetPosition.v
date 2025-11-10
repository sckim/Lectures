`timescale 1ns / 1ps
module timeSetPosition(reset,	sw1, set_pos_out);
	input				reset;
	input				sw1;
	output [2:0]	set_pos_out;
	
	reg [2:0]		set_pos=3'b100;	
	
	always @ (posedge (sw1) or negedge reset) begin
		if (~reset)
			set_pos <= 3'b000;
		else	
			case(set_pos)
				3'b100 : set_pos <= 3'b010;
				3'b010 : set_pos <= 3'b001;
				3'b001 : set_pos <= 3'b100;
				default : set_pos <= 3'b100;
			endcase
	end
	assign set_pos_out = set_pos;
endmodule	