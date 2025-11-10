package my_package is
	constant adder_width	: integer := 4;
	constant result_width	: integer := 4;
	subtype adder_value is integer range 0 to 2**adder_width-1;
	subtype result_value is integer range 0 to 2**result_width-1;
end my_package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use work.my_package.all;

entity BCDAdder is
	port (clk			: in std_logic;
			a, b			: in adder_value;
			FND			: out std_logic_vector(6 downto 0);
			FNDSel1, FNDSel2	: out std_logic);
end BCDAdder;

architecture Behavioral of BCDAdder is
	signal 	clk100Hz	: std_logic;
	signal	result	: result_value;
	signal 	FNDVal2, FNDVal1	: std_logic_vector(6 downto 0);
	signal	c			: std_logic;
begin
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

	process(a, b)
		variable mid_sum	: integer;
	begin
		mid_sum := a + b;	

		if mid_sum < 10 then
			result <= mid_sum;
			c <= '0';
		else
			result <= mid_sum + 6;
			c <= '1';
		end if;
	end process;

-- process for 7-segment display
	process(result, c)
	begin
		case result is
--							   "abcdefg-"
			when 0	=> FNDVal1 <= "1111110"; 
			when 1	=> FNDVal1 <= "0110000"; 
			when 2	=> FNDVal1 <= "1101101"; 
			when 3	=> FNDVal1 <= "1111001"; 
			when 4	=> FNDVal1 <= "0110011"; 
			when 5	=> FNDVal1 <= "1011011"; 
			when 6	=> FNDVal1 <= "1011111"; 
			when 7	=> FNDVal1 <= "1110000"; 
			when 8	=> FNDVal1 <= "1111111"; 
			when 9	=> FNDVal1 <= "1110011"; 
			when others	=>FNDVal1 <= "0000000"; 
		end case;
		
		case c is
--							  	     "abcdefg-"
			when '1'	=> FNDVal2 <= "0110000"; 
			when others	=> FNDVal2 <= "0000000"; 
		end case;
	end process;

	process(clk100Hz, FNDVal2, FNDVal1)
	begin
		if (clk100Hz = '1') then
			FNDSel2 <= '1';
			FNDSel1 <= '0';
			FND <= FNDVal1;
		else	
			FNDSel2 <= '0';
			FNDSel1 <= '1';
			FND <= FNDVal2;
		end if;
	end process;
end Behavioral;

