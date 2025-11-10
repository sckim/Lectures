-- divide by 1000000 clk
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY ClockDivide IS
	PORT(	clk							: in	std_logic;
			clk1hz_out					: out	std_logic);
END ClockDivide;

ARCHITECTURE Behavioral of ClockDivide IS
	signal		clk1hz				: std_logic;
BEGIN
	process(clk, clk1hz)
		variable		cnt1hz	: 	integer range 0 to 499999 := 0;
	begin
		if rising_edge(clk) then
			if cnt1hz >= 499999 then	
				cnt1hz := 0;
				clk1hz <= not clk1hz;
			else
				cnt1hz := cnt1hz + 1;
			end if;
		end if;
		clk1hz_out <= clk1hz;
	end process;
end Behavioral;