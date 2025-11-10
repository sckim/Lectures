library ieee;
use ieee.std_logic_1164.all;

package my_package is
	constant adder_width			: integer:=4;
	constant result_width		: integer:=5;
	subtype adder_value is integer range 0 to 2**adder_width-1;
	subtype result_value is integer range -2**result_width to 2**result_width-1;
end my_package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.my_package.all;

entity nBitAddSub2 is
	port(	clk				: in std_logic;
			a, b 				: in adder_value;
			m					: in std_logic;
			FND1, FND2		: out std_logic_vector(6 downto 0);
			FND2Sel, FND1Sel	: out	std_logic_vector(1 downto 0));
	end nBitAddSub2;

architecture Behavioral of nBitAddSub2 is
	signal clk100Hz			: std_logic;
	signal sign					: std_logic;
	signal FND1Val2, FND1Val1	: std_logic_vector(6 downto 0);
	signal hex2, hex1		: integer range 0 to 15;
		
begin
	process(m, a, b)
		variable result			: result_value;
	begin
		if (m = '0') then result := a + b;
		else result := a - b;
		end if;
		
		if (result < 0) then 
			sign <= '1';
			hex2 <= -result / 16;
			hex1 <= -result mod 16;
		else 
			sign <= '0';
			hex2 <= result / 16;
			hex1 <= result mod 16;
		end if;
	end process;
	
	process(clk)
		variable	m	: integer := 0;
	begin
		if rising_edge(clk) then
			if m >= 4999 then
				m := 0;
				clk100Hz <= not clk100Hz;
			else
				m := m + 1;
			end if;
		end if;
	end process;		

	process(hex2, hex1)
	begin
		case hex2 is
--							           "abcdefg-"
			when 0	=> FND1Val2 <= "1111110"; 
			when 1	=> FND1Val2 <= "0110000"; 
			when 2	=> FND1Val2 <= "1101101"; 
			when 3	=> FND1Val2 <= "1111001"; 
			when 4	=> FND1Val2 <= "0110011"; 
			when 5	=> FND1Val2 <= "1011011"; 
			when 6	=> FND1Val2 <= "1011111"; 
			when 7	=> FND1Val2 <= "1110000"; 
			when 8	=> FND1Val2 <= "1111111"; 
			when 9	=> FND1Val2 <= "1110011"; 
			when 10	=> FND1Val2 <= "1111101"; 
			when 11	=> FND1Val2 <= "0011111"; 
			when 12	=> FND1Val2 <= "0001101"; 
			when 13	=> FND1Val2 <= "0111101"; 
			when 14	=> FND1Val2 <= "1101111"; 
			when 15	=> FND1Val2 <= "1000111"; 
		end case;
		
		case hex1 is
--							           "abcdefg-"
			when 0	=> FND1Val1 <= "1111110"; 
			when 1	=> FND1Val1 <= "0110000"; 
			when 2	=> FND1Val1 <= "1101101"; 
			when 3	=> FND1Val1 <= "1111001"; 
			when 4	=> FND1Val1 <= "0110011"; 
			when 5	=> FND1Val1 <= "1011011"; 
			when 6	=> FND1Val1 <= "1011111"; 
			when 7	=> FND1Val1 <= "1110000"; 
			when 8	=> FND1Val1 <= "1111111"; 
			when 9	=> FND1Val1 <= "1110011"; 
			when 10	=> FND1Val1 <= "1111101"; 
			when 11	=> FND1Val1 <= "0011111"; 
			when 12	=> FND1Val1<= "0001101"; 
			when 13	=> FND1Val1 <= "0111101"; 
			when 14	=> FND1Val1 <= "1101111"; 
			when 15	=> FND1Val1 <= "1000111"; 
		end case;
	end process;

	FND2Sel(1) <= '1';
	FND2Sel(0) <= '0';
	
	process(sign)
	begin
		if (sign = '1') then
			FND2 <= "0000001";
		else
			FND2 <= "0000000";
		end if;	
	end process;	
		
	process(clk100Hz, FND1Val2, FND1Val1)
	begin
		if (clk100Hz = '1') then
			FND1Sel(0) <= '0';
			FND1Sel(1) <= '1';
			FND1 <= FND1Val1;
		else	
			FND1Sel(0) <= '1';
			FND1Sel(1) <= '0';
			FND1 <= FND1Val2;
		end if;
	end process;
end Behavioral;