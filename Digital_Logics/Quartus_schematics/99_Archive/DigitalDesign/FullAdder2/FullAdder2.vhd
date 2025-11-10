library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullAdder2 is
	port(	x, y, z		: in	std_logic;
			S, C		: out 	std_logic);
end FullAdder2;

architecture Behavioral of FullAdder2 is

begin
	S <= (not x and not y and z) or (not x and y and not z) or (x and not y and not z) or (x and y and z);
	C <= (x and y) or (x and z) or (y and z);
end Behavioral;

