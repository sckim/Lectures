`timescale 1ns / 1ps
module TrafficLightController(clk, standby, test, G1Y1, R1G2, Y2R2, 
										G1en, Y1en, R1en, G2en, Y2en, R2en);
	input				clk, standby, test;
	output [6:0]	G1Y1, R1G2, Y2R2;
	output			G1en, Y1en, R1en, G2en, Y2en, R2en;
	
	reg [6:0]		G1Y1, R1G2, Y2R2;
	reg				G1en, Y1en, R1en, G2en, Y2en, R2en;
	
	parameter		YY=3'b000, RY=3'b001, GR=3'b010, YR=3'b011, RG=3'b100;
	reg [2:0]		state=YY;

	parameter		RGTime=10, RYTime=3, GRTime=15, YRTime=3, TESTTime=2;

	integer			TimeCnt, onTime;
	
	reg [6:0]		G1=7'b0000000, Y1=7'b0000000, R1=7'b0000000; 
	reg [6:0]		G2=7'b0000000, Y2=7'b0000000, R2=7'b0000000;	
	reg				clk1hz, clk100hz;
	integer			cnt1hz, cnt100hz;

	always @ (posedge clk) begin
		if (cnt1hz >= 499999) begin
			cnt1hz <= 0;
			clk1hz <= ~clk1hz;
		end else
			cnt1hz <= cnt1hz+1;
			
		if (cnt100hz >= 4999) begin
			cnt100hz <= 0;
			clk100hz <= ~clk100hz;
		end else
			cnt100hz <= cnt100hz+1;
	end		

// process for deciding next state and conditional output
	always @ (posedge clk1hz or posedge standby) begin
		if (standby) begin
			state <= YY;
			TimeCnt <= 0;
		end	else	
			case(state)
				RG: begin
					if (~test) onTime <= RGTime;
					else	onTime <= TESTTime;
					
					TimeCnt <= TimeCnt + 1;
					if (TimeCnt == onTime) begin
						state <= RY;
						TimeCnt <= 0;
					end;
				end	

				RY: begin
					if (~test) onTime <= RYTime;
					else	onTime <= TESTTime;
					
					TimeCnt <= TimeCnt + 1;
					if (TimeCnt == onTime) begin
						state <= GR;
						TimeCnt <= 0;
					end;
				end	
					
				GR: begin
					if (~test) onTime <= GRTime;
					else	onTime <= TESTTime;
					
					TimeCnt <= TimeCnt + 1;
					if (TimeCnt == onTime) begin
						state <= YR;
						TimeCnt <= 0;
					end;
				end
				
				YR: begin
					if (~test) onTime <= YRTime;
					else	onTime <= TESTTime;
					
					TimeCnt <= TimeCnt + 1;
					if (TimeCnt == onTime) begin
						state <= RG;
						TimeCnt <= 0;
					end
				end
				
				YY:
					state <= RY;
			endcase		
		
	end

	always @ (state) begin
		case(state)
			RG:begin
				R1 <= 7'b1111110; Y1 <= 7'b0000000; G1 <= 7'b0000000;
				R2 <= 7'b0000000; Y2 <= 7'b0000000; G2 <= 7'b1111110; 
				end
			RY:begin
				R1 <= 7'b1111110; Y1 <= 7'b0000000; G1 <= 7'b0000000;
				R2 <= 7'b0000000; Y2 <= 7'b1111110; G2 <= 7'b0000000;
				end	
			GR:begin
				R1 <= 7'b0000000; Y1 <= 7'b0000000; G1 <= 7'b1111110;
				R2 <= 7'b1111110; Y2 <= 7'b0000000; G2 <= 7'b0000000; 
				end
			YR:begin
				R1 <= 7'b0000000; Y1 <= 7'b1111110; G1 <= 7'b0000000;
				R2 <= 7'b1111110; Y2 <= 7'b0000000; G2 <= 7'b0000000; 
				end
			YY:begin
				R1 <= 7'b0000000; Y1 <= 7'b1111110; G1 <= 7'b0000000;
				R2 <= 7'b0000000; Y2 <= 7'b1111110; G2 <= 7'b0000000; 
				end
			default:;	
		endcase
	end		
			
	always @ (clk100hz or G1, Y1, R1, G2, Y2, R2) begin
		if(clk100hz) begin
			G1en <= 1'b0;
			Y1en <= 1'b1;
			R1en <= 1'b0;
			G2en <= 1'b1;
			Y2en <= 1'b0;
			R2en <= 1'b1;
			G1Y1 <= G1;
			R1G2 <= R1;
			Y2R2 <= Y2;
		end else begin
			G1en <= 1'b1;
			Y1en <= 1'b0;
			R1en <= 1'b1;
			G2en <= 1'b0;
			Y2en <= 1'b1;
			R2en <= 1'b0;
			G1Y1 <= Y1;
			R1G2 <= G2;
			Y2R2 <= R2;
		end
	end
endmodule	