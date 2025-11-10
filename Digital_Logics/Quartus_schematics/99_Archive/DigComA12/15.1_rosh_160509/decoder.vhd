-- Instruction decoder
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY decoder IS
	PORT(	nRESET				: in	std_logic;
			clk					: IN	std_logic;
			decode_enable		: in	std_logic;
			ir_decode			: in	std_logic_vector(2 downto 0);
			d						: out 	std_logic_vector(7 downto 0));
END decoder;

 ARCHITECTURE design of decoder IS

	signal		ir_buf	: std_logic_vector(2 downto 0);		
BEGIN
	PROCESS (clk, nRESET, decode_enable)
		variable ir_sig	: std_logic_vector(2 downto 0);
	BEGIN
		if nRESET = '0' then
			d <= "00000000";

		elsif (falling_edge(clk) and decode_enable = '1') then
			ir_sig := ir_decode;
			case ir_sig is
				when "000" => d <= "00000001";
				when "001" => d <= "00000010";
				when "010" => d <= "00000100";
				when "011" => d <= "00001000";
				when "100" => d <= "00010000";
				when "101" => d <= "00100000";
				when "110" => d <= "01000000";
				when "111" => d <= "10000000";
			end case;
		end if;
	end process;
END design;