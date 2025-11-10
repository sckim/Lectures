library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity SimpleStateMachine is
	port (clk, rst, i, m, n	: in std_logic;
			y						: out std_logic);
end SimpleStateMachine;

architecture Behavioral of SimpleStateMachine is
	type state_type is (S0, S1);
	signal state, next_state	: state_type;
begin

	process (rst, clk)
	begin
		if rst= '0' then
			state <= S0;
		elsif rising_edge(clk) then
			state <= next_state;
		end if;
	end process;
	
	process (i, state)
	begin
		case state is 
			when S0 =>
				if (i = '1') then next_state <= S1;
				else next_state <= S0;
				end if;
			when S1 =>
				if (i = '1') then next_state <= S0;
				else next_state <= S1;
				end if;
		end case;
	end process;
	
	y <= m when state = S0 else
		 n;	
end Behavioral;