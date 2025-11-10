`timescale 1ns / 1ps
module ParallelSerialConvertor(clk, load, p_in, s_out);
	input				clk, load;
	input[7:0]		p_in;
	output[7:0]		s_out;

	reg[7:0]			reg1=8'h00, s_reg=8'h00;
	
	always @ (posedge clk) begin
		if (load)
			reg1 <= p_in;
		else begin
			s_reg <= {s_reg[6:0], reg1[7]};
			reg1 <= {reg1[6:0], 1'b0};
		end
	end
	assign s_out = s_reg;
endmodule	