`timescale 1ns / 1ps
module MasterSelect(reset,	clk, sw0, sw1, clk1hz_out, mode_out, set_pos_out, clk100hz_out);

	input				reset, clk;
	input				sw0, sw1;
	output [1:0]	mode_out;
	output [2:0]	set_pos_out;
	output			clk1hz_out, clk100hz_out;
	
	reg [2:0]		set_pos_out;

	integer			cnt1hz, cnt100hz = 0;
	reg [2:0]		set_pos = 3'b100;
	reg [1:0]		mode = 2'b00;
	reg 				clk1hz, clk100hz;

// 1Hz clock generation
	always @ (posedge (clk)) begin
		if (cnt1hz >= 499999) begin
			cnt1hz <= 0;
			clk1hz <= ~clk1hz;
		end else
			cnt1hz <= cnt1hz+1;
	end
	assign clk1hz_out = clk1hz;

// 100Hz clock generation
	always @ (posedge (clk)) begin
		if (cnt100hz >= 4999) begin
			cnt100hz <= 0;
			clk100hz <= ~clk100hz;
		end else
			cnt100hz <= cnt100hz+1;
	end
	assign clk100hz_out = clk100hz;
	
	always @ (posedge (sw0) or negedge reset) begin
		if (~reset)
			mode <= 2'b00;
		else
			mode <= mode + 1'b1;
	end
	assign mode_out = mode;

	always @ (posedge (sw1) or negedge reset) begin
		if (~reset)
			set_pos <= 3'b100;
		else
			if ((mode == 2'b01) || (mode == 2'b10))
				case(set_pos)
					3'b100 : set_pos <= 3'b010;
					3'b010 : set_pos <= 3'b001;
					3'b001 : set_pos <= 3'b100;
					default : set_pos <= 3'b100;
				endcase
			else
				set_pos <= 3'b000;
	end
	
	always @ ( mode or set_pos) begin
		case(mode)
			2'b01, 2'b10 : 
				set_pos_out <= set_pos;
			default :
				set_pos_out <= 3'b000;
		endcase		
	end
endmodule	
