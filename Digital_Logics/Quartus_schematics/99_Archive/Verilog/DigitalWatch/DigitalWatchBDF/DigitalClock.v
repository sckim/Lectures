`timescale 1ns / 1ps
module DigitalClock(reset,	clk, clk1hz, mode, set_pos, sw2, sec_out, min_out, hour_out);

	input				reset, clk, clk1hz;
	input [1:0]    mode;
	input [2:0]		set_pos;
	input				sw2;
	
	output [5:0]	sec_out, min_out;
	output [4:0]	hour_out;

	reg				timeClock;
	reg [4:0]		hour;
	reg [5:0]		min, sec;

	// always for clock source
	always @ (posedge (clk)) begin
		if (mode == 2'b01)
			timeClock <= sw2;
		else
			timeClock <= clk1hz;
	end

// always for second
	always @ (posedge (timeClock) or negedge reset) begin
		if (~reset)
			sec <= 6'd0;
		else
			case (mode)
				2'b00, 2'b10, 2'b11 : 
					if (sec >= 6'd59)
						sec <= 6'd0;
					else
						sec <= sec + 1'b1;
				2'b01 : 	
					if (set_pos == 3'b001) begin // second time set
						if (sec >= 6'd59)
							sec <= 6'd0;
						else
							sec <= sec + 1'b1;
					end // if (set_pos == 3'b001)
			endcase		
	end				
				
// always for mininte
	always @ (posedge (timeClock) or negedge reset) begin
		if (~reset)
			min <= 6'd0;
		else
			case (mode)
				2'b00, 2'b10, 2'b11 : 
					if (sec >= 6'd59) begin 
						if (min >= 6'd59)
							min <= 6'd0;
						else
							min <=  min + 1'b1;
					end
				2'b01 : 	
					if (set_pos == 3'b010) begin	// minute time set
						if (min >= 6'd59)
							min <= 6'd0;
						else
							min <= min + 1'b1;
					end // if (set_pos == 3'b010)
			endcase
	end		
	
// always for hour
	always @ (posedge (timeClock) or negedge reset) begin
		if (~reset)
			hour <= 5'd0;
		else
			case (mode)
				2'b00, 2'b10, 2'b11 : 
					if (sec >= 6'd59) begin
						if (min >= 6'd59) begin
							if (hour >= 5'd23)
								hour <= 5'd0;
							else
								hour <= hour + 1'b1;
						end //min >= 6'd59
					end //sec >= 6'd59
					
				2'b01 : 
					if (set_pos == 3'b100) begin	// hour time set
						if (hour >= 6'd59) 
							hour <= 6'd0;
						else
							hour <= hour + 1'b1;
					end // if (set_pos == 3'b100)
			endcase	
	end //end always
	assign sec_out = sec;
	assign min_out = min;
	assign hour_out = hour;
endmodule