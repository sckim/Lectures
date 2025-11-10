-- mode selection by switch 0
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY modeSelect IS
	PORT(	reset					: in	std_logic;
			sw0					: in	std_logic;
			mode_out				: out	std_logic_vector(1 downto 0));
END modeSelect;

ARCHITECTURE Behavioral of modeSelect IS
		signal	mode		: std_logic_vector(1 downto 0);
begin
	process(reset, sw0)
	begin
		if reset = '0' then
			mode <= "00";
		elsif rising_edge(sw0) then
			mode <= mode + '1';
		end if;
	end process;
	mode_out <= mode;
end Behavioral;