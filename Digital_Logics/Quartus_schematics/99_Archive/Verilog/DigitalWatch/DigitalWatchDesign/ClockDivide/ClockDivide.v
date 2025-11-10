`timescale 1ns / 1ps
module ClockDivide(clk, clk1hz_out);
	input				clk;
	output			clk1hz_out;
	
	reg 				clk1hz;
	integer			cnt1hz = 0;

// 1Hz clock generation
	always @ (posedge (clk)) begin
		if (cnt1hz >= 499999) begin
			cnt1hz <= 0;
			clk1hz <= ~clk1hz;
		end else
			cnt1hz <= cnt1hz+1;
	end
	assign clk1hz_out = clk1hz;	
endmodule