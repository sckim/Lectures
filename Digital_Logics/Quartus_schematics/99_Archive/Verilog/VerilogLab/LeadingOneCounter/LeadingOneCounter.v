`timescale 1ns / 1ps
module LeadingOneCounter(clk, d, FND, FNDSel1, FNDSel2, led);
	input				clk;
	input [7:0]		d;
	output[6:0]		FND;
	output			FNDSel1, FNDSel2;
	output[7:0]		led;

	reg [6:0]		FND;

	integer			oneCount, i;
	
	assign led = d;
	always @(d) begin : CountBlock
		oneCount = 0;
		i = 7;
		while (i>=0) begin
				case(d[i])
					0 : disable CountBlock;
					1 : oneCount=oneCount+1;
				endcase
				i=i-1;
		end
	end	

	assign FNDSel2 = 1'b1;
	assign FNDSel1 = 1'b0;

	always @(posedge clk) begin
		case(oneCount)
			0 : FND = 7'b1111110;
			1 : FND = 7'b0110000;
			2 : FND = 7'b1101101;
			3 : FND = 7'b1111001;
			4 : FND = 7'b0110011;
			5 : FND = 7'b1011011;
			6 : FND = 7'b1011111;
			7 : FND = 7'b1110000;
			8 : FND = 7'b1111111;
			default : FND = 7'b0000000;
		endcase
	end	
endmodule