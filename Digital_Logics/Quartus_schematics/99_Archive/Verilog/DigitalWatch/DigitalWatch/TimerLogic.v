`timescale 1ns / 1ps
module TimerLogic(reset, mode, clk100hz, sw1, sw2, mmsec_out, sec_out, min_out);
	input				reset;
	input [1:0]		mode;
	input				clk100hz;
	input				sw1, sw2;

	output [6:0]	mmsec_out;
	output [5:0] 	sec_out, min_out;

	reg [6:0]		mmsec;
	reg [5:0]		min, sec;
	reg				state; // 0 : stop state, 1 : up count state
	wire [3:0]		k;
	
// always for state control
	always @(posedge sw1 or negedge reset) begin
		if (~reset)
			state <= 1'b0;
		else
			case (mode)
				2'b11 : state <= ~state;
				default :;
			endcase	
	end

// always for 1/100 second
	assign k = {state, mode, sw2};
	always @(posedge(clk100hz) or negedge(reset)) begin
		if (~reset)
			mmsec <= 7'b0000000;
		else
			case (k)
				4'b0111 : mmsec <= 7'b0000000;
				4'b1000, 4'b1001, 4'b1010, 
				4'b1011, 4'b1100, 4'b1101,
				4'b1110,	4'b1111 : 
					if (mmsec >= 7'd99)
						mmsec <= 7'b0000000;
					else
						mmsec <= mmsec + 1'b1;
				default :;
			endcase
	end

// always for second
	always @(posedge(clk100hz) or negedge(reset)) begin
		if (~reset)
			sec <= 6'b000000;
		else
			case (k)
				4'b0111 : sec <= 6'b000000;
				4'b1000, 4'b1001, 4'b1010, 
				4'b1011, 4'b1100, 4'b1101,
				4'b1110,	4'b1111 : 
				if (mmsec >= 7'd99)
						if (sec >= 6'd59)
							sec <= 6'b000000;
						else
							sec <= sec + 1'b1;
				default :;
			endcase
	end

// always for min
	always @(posedge(clk100hz) or negedge(reset)) begin
		if (~reset)
			min <= 6'b000000;
		else
			case (k)
				4'b0111 : min <= 6'b000000;
				4'b1000, 4'b1001, 4'b1010, 
				4'b1011, 4'b1100, 4'b1101,
				4'b1110,	4'b1111 : 
					if (mmsec >= 7'd99)
						if (sec >= 6'd59)
							if (min >= 6'd59)
								min <= 6'b000000;
							else
								min <= min + 1'b1;
				default :;
			endcase
	end
	assign mmsec_out = mmsec;
	assign sec_out = sec;
	assign min_out = min;
endmodule