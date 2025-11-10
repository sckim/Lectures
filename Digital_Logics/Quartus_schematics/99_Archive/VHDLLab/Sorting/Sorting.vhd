package my_package is
	constant input_width	: integer := 4;
	constant output_width	: integer := 4;
	subtype input_value is integer range 0 to 2**input_width-1;
	subtype output_value is integer range 0 to 2**output_width-1;
end my_package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use work.my_package.all;

entity Sorting is
	port (	clk						: std_logic;
				en							: std_logic;
				a, b						: in input_value;
				FNDin, FNDout			: out std_logic_vector(6 downto 0);
				FNDinSel, FNDoutSel	: out std_logic_vector(1 downto 0));
end Sorting;

architecture Behavioral of Sorting is
	signal	max, min				: output_value;	
	signal	clk100Hz				: std_logic;
	signal	FNDin1, FNDin2, FNDout1, FNDout2	: std_logic_vector(6 downto 0);

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

	process(clk, a, b, en)
	begin
		if rising_edge(clk) then
			if en = '0' then
				if a > b then
					max <= a;
					min <= b;
				else
					max <= b;
					min <= a;
				end if;
			end if;
		end if;
	end process;		

-- process for 7-segment display
	process(a, b, max, min)
	begin
		case a is
--					     "abcdefg-"
			when 0	=> FNDin2 <= "1111110"; 
			when 1	=> FNDin2 <= "0110000"; 
			when 2	=> FNDin2 <= "1101101"; 
			when 3	=> FNDin2 <= "1111001"; 
			when 4	=> FNDin2 <= "0110011"; 
			when 5	=> FNDin2 <= "1011011"; 
			when 6	=> FNDin2 <= "1011111"; 
			when 7	=> FNDin2 <= "1110000"; 
			when 8	=> FNDin2 <= "1111111"; 
			when 9	=> FNDin2 <= "1110011"; 
			when 10	=> FNDin2 <= "1111101"; 
			when 11	=> FNDin2 <= "0011111"; 
			when 12	=> FNDin2 <= "0001101"; 
			when 13	=> FNDin2 <= "0111101"; 
			when 14	=> FNDin2 <= "1101111"; 
			when 15	=> FNDin2 <= "1000111"; 
		end case;

		case b is
--					     "abcdefg-"
			when 0	=> FNDin1 <= "1111110"; 
			when 1	=> FNDin1 <= "0110000"; 
			when 2	=> FNDin1 <= "1101101"; 
			when 3	=> FNDin1 <= "1111001"; 
			when 4	=> FNDin1 <= "0110011"; 
			when 5	=> FNDin1 <= "1011011"; 
			when 6	=> FNDin1 <= "1011111"; 
			when 7	=> FNDin1 <= "1110000"; 
			when 8	=> FNDin1 <= "1111111"; 
			when 9	=> FNDin1 <= "1110011"; 
			when 10	=> FNDin1 <= "1111101"; 
			when 11	=> FNDin1 <= "0011111"; 
			when 12	=> FNDin1 <= "0001101"; 
			when 13	=> FNDin1 <= "0111101"; 
			when 14	=> FNDin1 <= "1101111"; 
			when 15	=> FNDin1 <= "1000111"; 
		end case;
	
		case max is
--					     "abcdefg-"
			when 0	=> FNDout2 <= "1111110"; 
			when 1	=> FNDout2 <= "0110000"; 
			when 2	=> FNDout2 <= "1101101"; 
			when 3	=> FNDout2 <= "1111001"; 
			when 4	=> FNDout2 <= "0110011"; 
			when 5	=> FNDout2 <= "1011011"; 
			when 6	=> FNDout2 <= "1011111"; 
			when 7	=> FNDout2 <= "1110000"; 
			when 8	=> FNDout2 <= "1111111"; 
			when 9	=> FNDout2 <= "1110011"; 
			when 10	=> FNDout2 <= "1111101"; 
			when 11	=> FNDout2 <= "0011111"; 
			when 12	=> FNDout2 <= "0001101"; 
			when 13	=> FNDout2 <= "0111101"; 
			when 14	=> FNDout2 <= "1101111"; 
			when 15	=> FNDout2 <= "1000111"; 
		end case;
		
		case min is
--					     "abcdefg-"
			when 0	=> FNDout1 <= "1111110"; 
			when 1	=> FNDout1 <= "0110000"; 
			when 2	=> FNDout1 <= "1101101"; 
			when 3	=> FNDout1 <= "1111001"; 
			when 4	=> FNDout1 <= "0110011"; 
			when 5	=> FNDout1 <= "1011011"; 
			when 6	=> FNDout1 <= "1011111"; 
			when 7	=> FNDout1 <= "1110000"; 
			when 8	=> FNDout1 <= "1111111"; 
			when 9	=> FNDout1 <= "1110011"; 
			when 10	=> FNDout1 <= "1111101"; 
			when 11	=> FNDout1 <= "0011111"; 
			when 12	=> FNDout1 <= "0001101"; 
			when 13	=> FNDout1 <= "0111101"; 
			when 14	=> FNDout1 <= "1101111"; 
			when 15	=> FNDout1 <= "1000111"; 
		end case;
	end process;

	process(clk100Hz, FNDin1, FNDin2, FNDout1, FNDout2)
	begin
		if (clk100Hz = '1') then
			FNDinSel(0) <= '0';
			FNDinSel(1) <= '1';
			FNDin <= FNDin1;
			FNDoutSel(0) <= '0';
			FNDoutSel(1) <= '1';
			FNDout <= FNDout1;
		else	
			FNDinSel(0) <= '1';
			FNDinSel(1) <= '0';
			FNDin <= FNDin2;
			FNDoutSel(0) <= '1';
			FNDoutSel(1) <= '0';
			FNDout <= FNDout2;
		end if;
	end process;
end Behavioral;

