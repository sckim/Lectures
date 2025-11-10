library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity FullAdder3 is
	port (x, y, z		: in	integer range 0 to 1;
			S, C		: out 	std_logic);
end FullAdder3;

architecture Behavioral of FullAdder3 is
	signal sum			: std_logic_vector(1 downto 0);
begin
	process(x, y, z)
	begin
		sum <= conv_std_logic_vector(x + y + z, 2);
	end process;
	S <= sum(0);
	C <= sum(1);
end Behavioral;

