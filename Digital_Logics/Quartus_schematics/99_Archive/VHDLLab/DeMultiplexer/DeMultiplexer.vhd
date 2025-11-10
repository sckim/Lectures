library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DeMultiplexer is
	port(	s	: in std_logic_vector(1 downto 0);
			i 	: in std_logic;
			y	: out std_logic_vector(3 downto 0));
end DeMultiplexer;

architecture Behavioral of DeMultiplexer is

begin
	process(s, i)
	begin
		case s is	 
			when "00" => 
				y(0) <= i; y(1) <= 'Z'; y(2) <= 'Z'; y(3) <= 'Z';
			when "01" =>
				y(0) <= 'Z'; y(1) <= i; y(2) <= 'Z'; y(3) <= 'Z';
			when "10" => 
				y(0) <= 'Z'; y(1) <= 'Z'; y(2) <= i; y(3) <= 'Z';
			when "11" => 
				y(0) <= 'Z'; y(1) <= 'Z'; y(2) <= 'Z'; y(3) <= i;
			when others => null;	
		end case;
	end process;
end Behavioral;

