library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity FNDDecoderI is
	port(	clk					: in std_logic;
			key					: in std_logic_vector(15 downto 0);
			FND					: out std_logic_vector(6 downto 0);
			FNDSel2, FNDSel1	: out std_logic);

end FNDDecoderI;

architecture Behavioral of FNDDecoderI is
	signal keyVal		: std_logic_vector(3 downto 0);	
begin
	FNDSel2 <= '1';
	FNDSel1 <= '0';
-- process for key input
	process(clk, key)
	begin
		if rising_edge(clk) then
			case key(15 downto 0) is 
				when "0000000000000001" => keyVal <= "0000";
				when "0000000000000010" => keyVal <= "0001";
				when "0000000000000100" => keyVal <= "0010";
				when "0000000000001000" => keyVal <= "0011"; 
				when "0000000000010000" => keyVal <= "0100";
				when "0000000000100000" => keyVal <= "0101";
				when "0000000001000000" => keyVal <= "0110";
				when "0000000010000000" => keyVal <= "0111";
				when "0000000100000000" => keyVal <= "1000";
				when "0000001000000000" => keyVal <= "1001";
				when "0000010000000000" => keyVal <= "1010";
				when "0000100000000000" => keyVal <= "1011";
				when "0001000000000000" => keyVal <= "1100";
				when "0010000000000000" => keyVal <= "1101";
				when "0100000000000000" => keyVal <= "1110"; 
				when "1000000000000000" => keyVal <= "1111";
				when others => null;
			end case;
		end if;
	end process;

-- process for 7-segment display
	process(clk, keyVal)
	begin
		if rising_edge(clk) then
			case keyVal is
--								   		"abcdefg-"
				when "0000"	=> FND <= 	"1111110"; 
				when "0001"	=> FND <= 	"0110000"; 
				when "0010"	=> FND <= 	"1101101"; 
				when "0011"	=> FND <= 	"1111001"; 
				when "0100"	=> FND <= 	"0110011"; 
				when "0101"	=> FND <= 	"1011011"; 
				when "0110"	=> FND <= 	"1011111"; 
				when "0111"	=> FND <= 	"1110000"; 
				when "1000"	=> FND <= 	"1111111"; 
				when "1001"	=> FND <= 	"1110011"; 
				when "1010"	=> FND <= 	"1111101"; 
				when "1011"	=> FND <= 	"0011111"; 
				when "1100"	=> FND <= 	"0001101"; 
				when "1101"	=> FND <= 	"0111101"; 
				when "1110"	=> FND <= 	"1101111"; 
				when "1111"	=> FND <= 	"1000111"; 
				when others => null;
			end case;
		end if;	
	end process;	
end Behavioral;

