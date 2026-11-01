library ieee;
use ieee.std_logic_1164.all;

entity Bcd_7Segments is 
    port(bcd     : in std_logic_vector(3 downto 0);
         Display : out std_logic_vector(0 to 6));
end Bcd_7Segments;

architecture sample of Bcd_7Segments is 
begin 
	process(bcd)
   	begin 
    	case bcd is
			when "0000" => Display <= "0000001";
			when "0001" => Display <= "1001111";
			when "0010" => Display <= "0010010";
			when "0011" => Display <= "0000110";
			when "0100" => Display <= "1001100";
			when "0101" => Display <= "0100100";
			when "0110" => Display <= "1100000";
			when "0111" => Display <= "0001111";
			when "1000" => Display <= "0000000";
			when "1001" => Display <= "0001100";
			when others => Display <= "1111111";
		end case;
    end process;
end sample;