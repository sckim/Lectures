-- mode selection by switch 0
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY timeSetPosition IS
	PORT(	reset						: in	std_logic;
			sw1						: in	std_logic;
			set_pos_out				: out	std_logic_vector(2 downto 0));
END timeSetPosition;

ARCHITECTURE Behavioral of timeSetPosition IS
		signal	set_pos		: std_logic_vector(2 downto 0);
begin
	process(reset, sw1)
	begin
		if reset = '0' then
			set_pos <= "100";
		elsif rising_edge(sw1) then
			case set_pos is
				when "100" => 
					set_pos <= "010";
				when "010" => 
					set_pos <= "001";
				when "001" => 
					set_pos <= "100";
				when others => null;
			end case;
		end if;
	end process;	
	set_pos_out <= set_pos;
end Behavioral;