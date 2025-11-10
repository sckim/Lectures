library  ieee;
use  ieee.std_logic_1164.all;

entity AND2_behavior is
     port (in1, in2: in std_logic;
           out1: out std_logic);
end AND2_behavior;

architecture behavior of AND2_behavior is

begin
	process (in1, in2)
	begin
		out1 <= in1 and in2;
	end process;
	
end behavior;