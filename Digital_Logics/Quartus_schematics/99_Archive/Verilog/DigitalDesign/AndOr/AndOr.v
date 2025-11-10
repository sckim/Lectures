// Verilog code for logic gates
module AndOr(a, b, and_out, or_out, not_out);
	input	a, b;
	output and_out, or_out, not_out;
	assign and_out = a&b;
	assign or_out = a|b;
	assign not_out= ~a;
endmodule