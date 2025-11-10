library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ClockSync is
	port(	clk 		: in std_logic;
			a, b		: in std_logic;
			d, k		: out std_logic);
end ClockSync;

architecture Behavioral of ClockSync is
begin
	d <= a and b;
	
	process(clk)
	begin
		if rising_edge(clk) then
			k <= a and b;
		end if;
	end process;
end Behavioral;

