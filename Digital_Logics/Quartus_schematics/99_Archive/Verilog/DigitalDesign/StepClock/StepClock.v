`timescale 1ns / 1ps
module StepClock(rst, clk, stepSwitch, stepPulse);
	input 		rst, clk, stepSwitch;
	output  		stepPulse;

	reg			stepPulse;
	reg			state;
	reg			clk1Hz;
	integer		m=0;
	
	parameter 	S0=1'b0, S1=1'b1;
	
	always @ (posedge (clk)) begin
		if (m >= 499999) begin
			m <= 0;
			clk1Hz <= ~clk1Hz;
		end else
			m <= m+1;
	end		

	always @(posedge clk1Hz or negedge rst)
   begin
		if(~rst)
			state <= S0;
      else
			case(state)
				S0:
					if(stepSwitch) begin
						state <= S1;
						stepPulse <= 1'b1;
					end else state <= S0;
				S1:
					if(stepSwitch) begin
						state <= S1;
						stepPulse <= 1'b0;
					end else begin
						state <= S0;
						stepPulse <= 1'b0;
					end	
			endcase
	end
endmodule