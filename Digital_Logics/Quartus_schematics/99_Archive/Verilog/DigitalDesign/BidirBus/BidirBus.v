`timescale 1ns / 1ps
module BidirBus (oe, clk, inp, outp, bidir);
	input   oe;
	input   clk;
	input   [7:0] inp;
	output  [7:0] outp;
	inout   [7:0] bidir;

	reg     [7:0] a;
	reg     [7:0] b;

	assign bidir = oe ? a : 8'bZ ;
	assign outp  = oe ? 8'bz : b;

	always @ (posedge clk)
	begin
		b <= bidir;
		a <= inp;
	end
endmodule
// oe : '1'이면 inout 단자 bidir이 출력, '0'이면 입력으로 동작
// oe이 '1'이면 reg a[7:0]을 inout bidir로 출력하고, '0'이면 'Z' high impedence 상태가 된다. 
// 즉, 입력 단자가 된다.
// always 블럭에서 reg a[7:0]은 inp 입력을 받으며, oe 신호가 '1'이면 이 값을 inout 단자로 출력한다.
// always 블럭에서 reg b[7:0]은 inout에서 입력을 받으며, "assign outp = b" 문장에 의해서 
// oe이 '0'일때 outp 단자로 출력된다. 