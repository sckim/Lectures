module Halfadder(C, S, in1, in2);

	input in1, in2;
	output C, S;
	
	and #5 and1(C, in1, in2);
	xor #10 xor1(S, in1, in2);
	
endmodule