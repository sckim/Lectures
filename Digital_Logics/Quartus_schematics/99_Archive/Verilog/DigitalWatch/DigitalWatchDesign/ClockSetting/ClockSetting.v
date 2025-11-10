`timescale 1ns / 1ps
module ClockSetting(reset,	clk, sw0, sw1, sw2, hourFND, minFND, secFND,	
						hourFNDSel2, hourFNDSel1, minFNDSel2, minFNDSel1, secFNDSel2, 
						secFNDSel1, mode_out, set_pos_out);

	input				reset, clk;
	input				sw0, sw1, sw2;
	output [6:0]	hourFND, minFND, secFND;
	output 			hourFNDSel2, hourFNDSel1;
	output 			minFNDSel2, minFNDSel1;
	output 			secFNDSel2, secFNDSel1;
	output [1:0]	mode_out;
	output [2:0]	set_pos_out;

	integer			cnt1hz, cnt100hz = 0;
	reg				timeClock;
	reg [2:0]		set_pos;
	reg [1:0]		mode;
	reg [6:0]		hourFND, minFND, secFND;
	reg 				hourFNDSel2, hourFNDSel1;
	reg 				minFNDSel2, minFNDSel1;
	reg 				secFNDSel2, secFNDSel1;	
	reg 				clk1hz, clk100hz;

	reg [4:0]		hour;
	reg [5:0]		min, sec;

	reg [3:0]		hour10, hour0;
	reg [3:0]		min10, min0;
	reg [3:0]		sec10, sec0;
	reg [6:0]		FNDhour10, FNDhour0;
	reg [6:0]		FNDmin10, FNDmin0;
	reg [6:0]		FNDsec10, FNDsec0;	

// 1Hz clock generation
	always @ (posedge (clk)) begin
		if (cnt1hz >= 499999) begin
			cnt1hz <= 0;
			clk1hz <= ~clk1hz;
		end else
			cnt1hz <= cnt1hz+1;
	end

// 100Hz clock generation
	always @ (posedge (clk)) begin
		if (cnt100hz >= 4999) begin
			cnt100hz <= 0;
			clk100hz <= ~clk100hz;
		end else
			cnt100hz <= cnt100hz+1;
	end
	
	
	// always for clock source
	always @ (posedge (clk)) begin
		if (mode == 2'b01)
			timeClock <= sw2;
		else
			timeClock <= clk1hz;
	end

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
			case(set_pos)
				3'b100 : set_pos <= 3'b010;
				3'b010 : set_pos <= 3'b001;
				3'b001 : set_pos <= 3'b100;
				default : set_pos <= 3'b100;
			endcase
	end
	assign set_pos_out = set_pos;

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

// always for converting to integer
	always @ (hour, min, sec) begin
		hour10 <= hour/10;
		hour0 <= hour % 10;
		min10 <= min/10;
		min0 <= min % 10;
		sec10 <= sec/10;
		sec0 <= sec % 10;
	end

// always for 7-segment FND display	
	always @ (posedge clk) begin
		case (hour10)	  	     // abcdefg-
			4'd0 : FNDhour10 <= 7'b1111110;
			4'd1 : FNDhour10 <= 7'b0110000;
			4'd2 : FNDhour10 <= 7'b1101101;
			default :;
		endcase
		case (hour0)		    // abcdefg-
			4'd0 : FNDhour0 <= 7'b1111110;
			4'd1 : FNDhour0 <= 7'b0110000;
			4'd2 : FNDhour0 <= 7'b1101101;
			4'd3 : FNDhour0 <= 7'b1111001;
			4'd4 : FNDhour0 <= 7'b0110011;
			4'd5 : FNDhour0 <= 7'b1011011;
			4'd6 : FNDhour0 <= 7'b1011111;
			4'd7 : FNDhour0 <= 7'b1110000;
			4'd8 : FNDhour0 <= 7'b1111111;
			4'd9 : FNDhour0 <= 7'b1110011;
			default :;
		endcase
	
		case (min10)			 // abcdefg-
			4'd0 : FNDmin10 <= 7'b1111110;
			4'd1 : FNDmin10 <= 7'b0110000;
			4'd2 : FNDmin10 <= 7'b1101101;
			4'd3 : FNDmin10 <= 7'b1111001;
			4'd4 : FNDmin10 <= 7'b0110011;
			4'd5 : FNDmin10 <= 7'b1011011;
			default :;
		endcase
		
		case (min0)		      // abcdefg-
			4'd0 : FNDmin0 <= 7'b1111110;
			4'd1 : FNDmin0 <= 7'b0110000;
			4'd2 : FNDmin0 <= 7'b1101101;
			4'd3 : FNDmin0 <= 7'b1111001;
			4'd4 : FNDmin0 <= 7'b0110011;
			4'd5 : FNDmin0 <= 7'b1011011;
			4'd6 : FNDmin0 <= 7'b1011111;
			4'd7 : FNDmin0 <= 7'b1110000;
			4'd8 : FNDmin0 <= 7'b1111111;
			4'd9 : FNDmin0 <= 7'b1110011;
			default :;
		endcase

		case (sec10)			 // abcdefg-
			4'd0 : FNDsec10 <= 7'b1111110;
			4'd1 : FNDsec10 <= 7'b0110000;
			4'd2 : FNDsec10 <= 7'b1101101;
			4'd3 : FNDsec10 <= 7'b1111001;
			4'd4 : FNDsec10 <= 7'b0110011;
			4'd5 : FNDsec10 <= 7'b1011011;
			default :;
		endcase
		
		case (sec0)		      // abcdefg-
			4'd0 : FNDsec0 <= 7'b1111110;
			4'd1 : FNDsec0 <= 7'b0110000;
			4'd2 : FNDsec0 <= 7'b1101101;
			4'd3 : FNDsec0 <= 7'b1111001;
			4'd4 : FNDsec0 <= 7'b0110011;
			4'd5 : FNDsec0 <= 7'b1011011;
			4'd6 : FNDsec0 <= 7'b1011111;
			4'd7 : FNDsec0 <= 7'b1110000;
			4'd8 : FNDsec0 <= 7'b1111111;
			4'd9 : FNDsec0 <= 7'b1110011;
			default :;
			
		endcase
	end

	always @ (clk100hz, FNDhour10, FNDhour0, FNDmin10, FNDmin0, FNDsec10, FNDsec0) begin
		if (clk100hz == 1'b1) begin
			hourFNDSel1 <= 1'b0;
			hourFNDSel2 <= 1'b1;
			hourFND <= FNDhour0;
			minFNDSel1 <= 1'b0;
			minFNDSel2 <= 1'b1;
			minFND <= FNDmin0;
			secFNDSel1 <= 1'b0;
			secFNDSel2 <= 1'b1;
			secFND <= FNDsec0;
		end else begin
			hourFNDSel1 <= 1'b1;
			hourFNDSel2 <= 1'b0;
			hourFND <= FNDhour10;
			minFNDSel1 <= 1'b1;
			minFNDSel2 <= 1'b0;
			minFND <= FNDmin10;
			secFNDSel1 <= 1'b1;
			secFNDSel2 <= 1'b0;
			secFND <= FNDsec10;
		end
	end	
endmodule