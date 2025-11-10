`timescale 1ns / 1ps
module FNDDisplay(clk, clk100hz, sec, min, hour, hourFND, minFND, secFND,
					hourFNDSel2, hourFNDSel1, minFNDSel2, minFNDSel1, secFNDSel2, secFNDSel1);

	input				clk, clk100hz;
	input	[4:0]		hour;
	input	[5:0]		min, sec;
	
	output [6:0]	hourFND, minFND, secFND;
	output 			hourFNDSel2, hourFNDSel1;
	output 			minFNDSel2, minFNDSel1;
	output 			secFNDSel2, secFNDSel1;

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