library ieee;
use ieee.std_logic_1164.all;
 
entity half_adder is
    port (a,b : in bit ;
          s,c : out bit);
end half_adder;
 
architecture arc of half_adder is
begin
    s<= a xor b;
    c <= a and b;
end arc;