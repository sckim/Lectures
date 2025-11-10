`timescale 1ns / 1ps
module UpDownCounter(reset, stepClk, UpDown, cnt_out, FND, FNDSel2, FNDSel1);
	input				reset, stepClk, UpDown;
	output [1:0]	cnt_out;
	output [6:0]	FND;
	output			FNDSel2, FNDSel1;

	reg [6:0]		FND;
	wire				FNDSel2=1'b1, FNDSel1=1'b0;

	parameter 		S0=2'b00, S1=2'b01, S2=2'b10,S3=2'b11;
	reg [1:0]		state=S0;

	always @(posedge stepClk or negedge reset) begin
		if (~reset)
			state <= S0;
		else
			case(state)
				S0:
					if(~UpDown) 	state <= S1;
					else				state <= S3;
				S1:
					if(~UpDown) 	state <= S2;
					else				state <= S0;
				S2:
					if(~UpDown) 	state <= S3;
					else				state <= S1;
				S3:
					if(~UpDown) 	state <= S0;
					else				state <= S2;
			endcase
	end	

	always @(state)
	begin
		case(state)
			S0 : FND = 7'b1111110;
			S1 : FND = 7'b0110000;
			S2 : FND = 7'b1101101;
			S3 : FND = 7'b1111001;
		endcase
	end
	assign cnt_out = state;
endmodule