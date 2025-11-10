library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity SequenceDetector is
	port(	stepClk		: in	std_logic;
			reset	: in	std_logic;
			inp	: in	std_logic;
			outp	: out	std_logic);
end SequenceDetector;

architecture Behavioral of SequenceDetector is
	type state_type is (s0, s1, s2, s3);
	signal state	: state_type;
begin
	process (reset, stepClk)
	begin
		if reset = '0' then
			state <= s0;
		elsif rising_edge(stepClk) then
			case state is
				when s0=>
					if inp = '0' then
						state <= s0;
					else
						state <= s1;
					end if;
				when s1=>
					if inp = '0' then
						state <= s0;
					else
						state <= s2;
					end if;
				when s2=>
					if inp = '0' then
						state <= s0;
					else
						state <= s3;
					end if;
				when s3=>
					if inp = '0' then
						state <= s0;
					else
						state <= s3;
					end if;
			end case;
		end if;
	end process;
	process(state)
	begin
		case state is
			when s0 => outp <= '0';
			when s1 => outp <= '0';
			when s2 => outp <= '0';
			when s3 => outp <= '1';
		end case;	
	end process;
end Behavioral;