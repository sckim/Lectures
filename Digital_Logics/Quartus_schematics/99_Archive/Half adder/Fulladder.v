module Fulladder(sum, c_out, in1, in2, c_in);
  input in1, in2, c_in;
  output sum, c_out;
  
  wire s1, c1, c2;
  
  Halfadder HA1(c1, s1, in1, in2);
  Halfadder HA2(c2, sum, s1, c_in);
  
  xor xor1(c_out, c1, c2);
  
endmodule
  