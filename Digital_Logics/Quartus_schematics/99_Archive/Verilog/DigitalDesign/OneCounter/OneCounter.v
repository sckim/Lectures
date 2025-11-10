`timescale 1ns / 1ps
module OneCounter(d, FND, FNDSel2, FNDSel1);
	input [7:0]		d;
	output[6:0]		FND;
	output			FNDSel2, FNDSel1;

	reg [6:0]		FND;
	wire				FNDSel2, FNDSel1;

	integer			oneCount, i=0;
	
	always @(d or oneCount) begin
		oneCount = 0;
		for(i=0;i<8;i=i+1)
			begin
				if(d[i]) 
					oneCount=oneCount+1;
			end
	end		

	assign FNDSel2 = 1'b1;
	assign FNDSel1 = 1'b0;

	always @(oneCount) begin
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
			default : FND = 7'b1011011;
		endcase
	end	
endmodule