library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LeadingOneCounter is
	port(	-- clk					: in std_logic;
			d						: in	std_logic_vector(7 downto 0);
			FND					: out	std_logic_vector(6 downto 0);
			FNDSel2, FNDSel1	: out std_logic;
			led					: out std_logic_vector(7 downto 0));
end LeadingOneCounter;

architecture Behavioral of LeadingOneCounter is
begin
	led <= d;
	process(d)
		variable i	: integer range -1 to 7;
		variable oneCount	: integer range 0 to 8;
	begin
			oneCount := 0;
			i := 7;
			while (i >= d'right) loop
				case d(i) is
					when '1' => oneCount := oneCount + 1;
					when others => exit;
				end case;
				i := i-1;
			end loop;
		FNDSel2 <= '1';
		FNDSel1 <= '0';
			case oneCount is
--										"abcdefg-"
				when 0 => FND <= 	"1111110"; 
				when 1 => FND <= 	"0110000";
				when 2 => FND <= 	"1101101"; 
				when 3 => FND <= 	"1111001"; 
				when 4 => FND <= 	"0110011"; 
				when 5 => FND <= 	"1011011"; 
				when 6 => FND <= 	"1011111"; 
				when 7 => FND <= 	"1110000"; 
				when 8 => FND <= 	"1111111"; 
				when others => FND <= 	"0000000"; 
			end case;
	end process;
end Behavioral;