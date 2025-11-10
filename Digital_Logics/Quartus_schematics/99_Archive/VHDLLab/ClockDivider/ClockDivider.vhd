library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity ClockDivider is
	port (	reset		: in std_logic;
			inClk		: in std_logic;
			outClk		: out std_logic);
end ClockDivider;

architecture Behavioral of ClockDivider is
	type state_type is (s0, s1);
	signal state, next_state	: state_type	:= s0;
begin

	process(reset, inClk)
	begin
		if reset='0' then
			state <= s0;
		elsif rising_edge(inClk) then
			state <= next_state;
		end if;
	end process;

	process(inClk, state)
		variable clkCount	: integer	:= 0;
	begin
		if falling_edge(inCLK) then
			case state is
				when s0 =>
					clkCount := clkCount + 1;
						if clkCount >= 500000 then
							next_state <= s1;
							clkCount := 0;
						else 
							next_state <= s0;
						end if;
				when s1 =>
					clkCount := clkCount + 1;
					if clkCount >= 500000 then
						next_state <= s0;
						clkCount := 0;
					else 
						next_state <= s1;
					end if;
			end case;
		end if;		
	end process;
	outClk <= '0' when state = S0 else '1';
end Behavioral;