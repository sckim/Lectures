`timescale 1ns / 1ps
module SimpleStateMachine(clk, rst, i, m, n, y);
	input 		clk, rst, i, m, n;
	output  		y;

	reg			y;
	reg 			state;
	reg			next_state;

	parameter S0=1'b0, S1=1'b1;

	always @(posedge clk)
		if (~rst) 	state = S0;
		else			state = next_state;
	
	always @(i or state)
		case(state)
			S0:
				if(i) next_state = S1;
				else  next_state = S0;
			S1:
				if(i) next_state = S0;
				else  next_state = S1;
		endcase

	always @(state or m or n) 
		case (state)
			S0: y = m;
			S1: y = n;
		endcase
endmodule