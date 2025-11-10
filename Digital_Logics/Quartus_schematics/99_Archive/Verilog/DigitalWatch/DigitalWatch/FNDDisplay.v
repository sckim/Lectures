`timescale 1ns / 1ps
module FNDDisplay(reset, clk, clk2hz, clk100hz, sw2, mode, set_pos, dc_sec, dc_min, dc_hour,
					tl_mmsec, tl_sec, tl_min, al_sec, al_min, al_hour, hourFND, minFND, secFND, 
					hourFNDSel2, hourFNDSel1, minFNDSel2, minFNDSel1, secFNDSel2, secFNDSel1, blink_out);

	input				reset;
	input				clk, clk2hz, clk100hz;
	input				sw2;
	input	[1:0]		mode;
	input [2:0]		set_pos;
	input	[4:0]		dc_hour;
	input	[5:0]		dc_min, dc_sec;
	input	[6:0]		tl_mmsec;
	input	[5:0]		tl_sec, tl_min;
	input	[4:0]		al_hour;
	input	[5:0]		al_min, al_sec;

	output [6:0]	hourFND, minFND, secFND;
	output 			hourFNDSel2, hourFNDSel1;
	output 			minFNDSel2, minFNDSel1;
	output 			secFNDSel2, secFNDSel1;
	output			blink_out;

	reg [6:0]		hourFND, minFND, secFND;
	reg 				hourFNDSel2, hourFNDSel1;
	reg 				minFNDSel2, minFNDSel1;
	reg 				secFNDSel2, secFNDSel1;	

	reg [3:0]		hour10, hour0;
	reg [3:0]		min10, min0;
	reg [3:0]		sec10, sec0;
	reg [6:0]		FNDhour10, FNDhour0;
	reg [6:0]		FNDmin10, FNDmin0;
	reg [6:0]		FNDsec10, FNDsec0;
	reg				blink = 1'b1;
// this signal blink synchronized with clk2hz	
	reg				disp_sec, disp_min, disp_hour; 
	
	reg [1:0] state;
	parameter s0=2'b00, s1=2'b01, s2=2'b10,s3=2'b11;
	
// always for 7-segment blink on/off
	always @(posedge clk2hz or negedge reset) begin
		if (~reset)
			blink <= 1'b1;
		else	
			case (state)
				s0:
					if ((mode == 2'b01)||(mode == 2'b10))
						if (sw2 == 1'b1) begin
							state <= s1;
							blink <= 1'b1;
						end else begin
							state <= s0;
							blink <= 1'b1;
						end
					else begin
						state <= s0;
						blink <= 1'b1;
					end
				s1:
					if ((mode == 2'b01)||(mode == 2'b10))
						if (sw2 == 1'b1) begin
							state <= s2;
							blink <= 1'b1;
						end else begin
							state <= s0;
							blink <= 1'b1;
						end
					else begin
						state <= s0;
						blink <= 1'b1;
					end
				s2:
					if ((mode == 2'b01)||(mode == 2'b10))
						if (sw2 == 1'b1) begin
							state <= s3;
							blink <= 1'b1;
						end else begin
							state <= s0;
							blink <= 1'b1;
						end
					else begin
						state <= s0;
						blink <= 1'b1;
					end
				s3:
					if ((mode == 2'b01)||(mode == 2'b10))
						if (sw2 == 1'b1) begin
							state <= s3;
							blink <= 1'b0;
						end else begin
							state <= s0;
							blink <= 1'b1;
						end
					else begin
						state <= s0;
						blink <= 1'b1;
					end
			endcase
		end
		assign blink_out = blink;
	
// always for display on/off
	always @ (posedge clk2hz) begin
		if ((mode == 2'b01)||(mode == 2'b10)) begin
			if (blink == 1'b1) begin
				case (set_pos)
					3'b100 : begin
						disp_hour <= ~disp_hour;
						disp_min <= 1'b1;
						disp_sec <= 1'b1;
					end	
					3'b010 : begin
						disp_hour <= 1'b1;
						disp_min <= ~disp_min;
						disp_sec <= 1'b1;
					end	
					3'b001 : begin
						disp_hour <= 1'b1;
						disp_min <= 1'b1;
						disp_sec <= ~disp_sec;
					end	
					default :;
				endcase
			end else begin
				disp_hour <= 1'b1;
				disp_min <= 1'b1;
				disp_sec <= 1'b1;
			end
		end else begin
			disp_hour <= 1'b1;
			disp_min <= 1'b1;
			disp_sec <= 1'b1;
		end
	end	
	
// always for converting to integer
	always @ (mode, dc_hour, dc_min, dc_sec, tl_min, tl_sec, tl_mmsec, al_hour, al_min, al_sec) begin
		case (mode)
			2'b00, 2'b01 : begin // digital clock, clock setting
				hour10 <= dc_hour/10;
				hour0 <= dc_hour % 10;
				min10 <= dc_min/10;
				min0 <= dc_min % 10;
				sec10 <= dc_sec/10;
				sec0 <= dc_sec % 10;
			end

			2'b10 : begin // alarm mode
				hour10 <= al_hour/10;
				hour0 <= al_hour % 10;
				min10 <= al_min/10;
				min0 <= al_min % 10;
				sec10 <= al_sec/10;
				sec0 <= al_sec % 10;
			end

			2'b11 : begin // timer mode
				hour10 <= tl_min/10;
				hour0 <= tl_min % 10;
				min10 <= tl_sec/10;
				min0 <= tl_sec % 10;
				sec10 <= tl_mmsec/10;
				sec0 <= tl_mmsec % 10;
			end
		endcase	
	end	

// always for 7-segment FND display	
	always @ (posedge clk) begin
		if (disp_hour == 1'b1) begin			
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
		end else begin
			FNDhour10 <= 7'b0000000;
			FNDhour0 <= 7'b0000000;
		end	
	
		if (disp_min == 1'b1) begin	
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
		end else begin	
			FNDmin10 <= 7'b0000000;
			FNDmin0 <= 7'b0000000;
		end			
			
		if (disp_sec == 1'b1) begin			
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
		end else begin	
			FNDsec10 <= 7'b0000000;
			FNDsec0 <= 7'b0000000;
		end		
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