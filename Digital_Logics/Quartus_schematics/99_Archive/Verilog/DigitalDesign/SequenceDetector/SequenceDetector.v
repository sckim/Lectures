`timescale 1ns / 1ps
module SequenceDetector(stepClk, reset, inp, outp);
	input stepClk, reset, inp;
	output outp;
	wire	outp;
	reg [1:0] state;
	parameter S0=2'b00, S1=2'b01, S2=2'b10,S3=2'b11;

	always @(posedge stepClk or negedge reset)
		if (~reset)
			state <= S0;
		else	
			case (state)
				S0: 	if (inp) state <= S1;
						else state <= S0;
				S1: 	if (inp) state <= S2;
						else state <= S0;
				S2: 	if (inp) state <= S3;
						else state <= S0;
				S3: 	if (inp) state <= S3;
						else state <= S0;
			endcase
		assign outp = (state == S3);
endmodule
