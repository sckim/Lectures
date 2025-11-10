library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY stepClkGen IS
	PORT
	(
		nRESET			: in	std_logic;
		clk				: IN	std_logic;
		clk20000		: in	std_logic;
		stepSwitch		: in	std_logic;

	-- clock out
		stepClkOut		: out	std_logic := '0'
	);
END stepClkGen;

ARCHITECTURE design of stepClkGen IS
	TYPE STATE_TYPE IS (s0, s1, s2, s3);
	attribute enum_encoding					: string;
	attribute enum_encoding of STATE_TYPE 	: type is "00 01 10 11";
	
	SIGNAL state	: STATE_TYPE;

	signal	clkOnOff		: std_logic := '0';
	signal	step_node		: std_logic := '1';

BEGIN

	process(nRESET, clk20000)
	begin
		if nRESET = '0' then
			step_node <= '1';
		elsif rising_edge(clk20000) then
			step_node <= stepSwitch;
		end if;
	end process;

	process(nRESET, clk, step_node)
	begin
		if nRESET = '0' then
			state <= s0;
			clkOnOff <= '0';
		elsif falling_edge(clk) then
			case state is 
				when s0 => 
					if step_node = '1' then
						state <= s0;
					else 
						state <= s1;
						clkOnOff <= '1';
					end if;
				when s1 => 
					state <= s2;
					clkOnOff <= '1';
				when s2 =>
					state <= s3;
					clkOnOff <= '0';
				when s3 =>
					if step_node = '1' then
						state <= s0;
					else 
						state <= s3;
					end if;
			end case;
		end if;
	end process;			
	stepClkOut <= clk and clkOnOff;
end;
