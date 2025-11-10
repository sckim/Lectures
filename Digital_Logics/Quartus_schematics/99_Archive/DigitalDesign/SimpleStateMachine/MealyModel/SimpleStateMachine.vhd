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
	
	process (i, state, m, n)
	begin
		case state is 
			when S0 =>
				if (i = '1') then 
					next_state <= S1;
					y <= n;
				else 
					next_state <= S0;
					y <= m;
				end if;
			when S1 =>
				if (i = '1') then 
					next_state <= S0;
					y <= m;
				else 
					next_state <= S1;
					y <= n;
				end if;
		end case;
	end process;
end Behavioral;