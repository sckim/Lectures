`timescale 1ns / 1ps
module ClockDivider(reset, inClk, outClk);
	input 		reset, inClk;
	output  		outClk;

	reg 			state, next_state;
	integer		clkCount=0;

	parameter S0=1'b0, S1=1'b1;

	always @(posedge inClk or negedge reset)
		if(~reset)	state = S0;
		else state = next_state;
		
	always @(posedge inClk)
   begin
		case(state)
			S0: begin
				clkCount = clkCount+1;	
				if(clkCount >= 500000) begin
					next_state = S1;
					clkCount = 0;
				end	
				else next_state = S0;
			end	
			S1: begin
				clkCount = clkCount+1;
				if(clkCount >= 500000) begin
					next_state = S0;
					clkCount = 0;
				end
				else next_state = S1;
			end	
		endcase
	end
	assign outClk = (state == S0) ? 1'b0 : 1'b1;	
endmodule