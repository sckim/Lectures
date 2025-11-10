`timescale 1ns / 1ps
module BCDCounter(clk, reset,	cnt_out,	FND,	FNDSel2, FNDSel1);
	input				clk, reset;
	output [3:0]	cnt_out;
	output [6:0]	FND;
	output			FNDSel2, FNDSel1;

	reg [6:0]		FND;
	wire				FNDSel1=1'b0, FNDSel2=1'b1;
	integer			m=0;
	reg				clk1Hz;
	
	reg [3:0]		state;
	parameter 		S0=4'b0000, S1=4'b0001, S2=4'b0010, S3=4'b0011, S4=4'b0100;
	parameter 		S5=4'b0101, S6=4'b0110, S7=4'b0111, S8=4'b1000, S9=4'b1001;

	always @ (posedge (clk)) begin
		if (m >= 499999) begin
			m <= 0;
			clk1Hz <= ~clk1Hz;
		end else
			m <= m+1;
	end		

	always @(posedge clk1Hz or negedge reset) begin
		if (~reset)
			state <= S0;
		else
			case(state)
				S0: state <= S1;
				S1: state <= S2;
				S2: state <= S3;
				S3: state <= S4;
				S4: state <= S5;
				S5: state <= S6;
				S6: state <= S7;
				S7: state <= S8;
				S8: state <= S9;
				S9: state <= S0;
				default : state <= S0;	
			endcase
	end	

	always @(state)
	begin
		case(state)
			S0 : FND = 7'b1111110;
			S1 : FND = 7'b0110000;
			S2 : FND = 7'b1101101;
			S3 : FND = 7'b1111001;
			S4 : FND = 7'b0110011;
			S5 : FND = 7'b1011011;
			S6 : FND = 7'b1011111;
			S7 : FND = 7'b1110000;
			S8 : FND = 7'b1111111;
			S9 : FND = 7'b1110011;
			default : FND = 7'b0000000;	
		endcase
	end
	assign cnt_out = state;
endmodule