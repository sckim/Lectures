`timescale 1ns / 1ps
module AlarmLogic(reset, clk, clk2hz, clk100hz, mode, blink, set_pos, clk_min, clk_hour, 
						sw2, sw3, sec_out, min_out, hour_out, alarm_out, alarm_on);
						
	input				reset;
	input				clk, clk2hz, clk100hz;
	input [1:0]		mode;
	input				blink;
	input [2:0] 	set_pos;
	input [5:0] 	clk_min;
	input [4:0] 	clk_hour;
	input				sw2, sw3;
	
	output [5:0] 	sec_out, min_out;
	output [4:0]	hour_out;
	output [2:0]	alarm_out, alarm_on;
	reg 				AlarmClock = 1'b0;	
	reg [2:0]		alarm_out, alarm_on;
	reg 				alarm = 1'b0;
	
	reg [4:0]		hour = 5'b00000;
	reg [5:0]		min, sec = 6'b000000;
	wire [2:0]		k;
	
// always for Alarm on/off
	always @(posedge sw3 or negedge reset) begin
		if (~reset) begin
			alarm <= 1'b0;
			alarm_on <= 3'b000;
		end else
			case (alarm)
				1'b0 : begin
					alarm <= 1'b1;
					alarm_on <= 3'b111;
				end	
				1'b1 : begin	
					alarm <= 1'b0;
					alarm_on <= 3'b000;
				end
			endcase
	end		

// always for Alarm clock source
	assign k = {mode, blink};
	always @(posedge(clk)) begin
		case (k)
			3'b101 : AlarmClock <= sw2;
			3'b100 : AlarmClock <= clk2hz;
			default :;
		endcase
	end
	
// always for second
	always @(posedge(AlarmClock) or negedge(reset)) begin
		if (~reset)
			sec <= 6'd0;
		else
			if ((mode == 2'b10) && (set_pos == 3'b001))
					if (sec >= 6'd59)
						sec <= 6'd0;
					else
						sec <= sec + 1'b1;
	end				
				
// always for minute
	always @(posedge(AlarmClock) or negedge(reset)) begin
		if (~reset)
			min <= 6'd0;
		else
			if ((mode == 2'b10) && (set_pos == 3'b010))
					if (min >= 6'd59)
						min <= 6'd0;
					else
						min <= min + 1'b1;
	end				

// always for hour
	always @(posedge(AlarmClock) or negedge(reset)) begin
		if (~reset)
			hour <= 5'd0;
		else
			if ((mode == 2'b10) && (set_pos == 3'b100))
					if (hour >= 5'd23)
						hour <= 5'd0;
					else
						hour <= hour + 1'b1;
	end				
	assign sec_out = sec;
	assign min_out = min;
	assign hour_out = hour;
	
// always for comparing between current time and alarm setting time
	always @(posedge(clk100hz)) begin
		if ((hour == clk_hour) && (min == clk_min) & 
			(mode != 2'b10) & (alarm == 1'b1))
				alarm_out <= 3'b111;
			else	
				alarm_out <= 3'b000;
	end				
endmodule