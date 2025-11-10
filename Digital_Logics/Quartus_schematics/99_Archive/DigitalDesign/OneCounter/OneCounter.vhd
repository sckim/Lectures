library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity OneCounter is
	port(	d 						: in std_logic_vector(7 downto 0);
			FND					: out std_logic_vector(6 downto 0);
			FNDSel2, FNDSel1	: out std_logic);
end OneCounter;

architecture Behavioral of OneCounter is
begin
	process(d)
		variable oneCount : integer;
	begin
		oneCount := 0;
		for i in d'range loop
			if d(i) = '1' then
				oneCount := oneCount + 1;
			end if;
		end loop;

		FNDSel2 <= '1';
		FNDSel1 <= '0';	
		
		case oneCount is
--									 "abcdefg-"
			when 0	=> FND <= "1111110"; 
			when 1	=> FND <= "0110000"; 
			when 2	=> FND <= "1101101"; 
			when 3	=> FND <= "1111001"; 
			when 4	=> FND <= "0110011"; 
			when 5	=> FND <= "1011011"; 
			when 6	=> FND <= "1011111"; 
			when 7	=> FND <= "1110000"; 
			when 8	=> FND <= "1111111"; 
			when others =>FND <= "0000000"; 
		end case;
    end process;
end Behavioral;