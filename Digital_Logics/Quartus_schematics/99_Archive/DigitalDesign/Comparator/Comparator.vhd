package my_package is
	constant ab_width	: integer := 4;
	subtype ab_value is integer range 0 to 2**ab_width-1;
end my_package;

library ieee;
use ieee.std_logic_1164.all;
use work.my_package.all;

entity Comparator is
	port(	a, b 								: in ab_value;
			aLessB, aGreaterb, aEqualb	: out std_logic);
end Comparator;

architecture Behavioral of Comparator is

begin
	process(a, b)
	begin
		if( a > b) then			
			aGreaterb <= '1';
			aLessB <= '0';
			aEqualb <= '0';					
		elsif (a < b) then			
			aGreaterb <= '0';
			aLessB <= '1';
			aEqualb <= '0';	
		else			
			aGreaterb <= '0';
			aLessB <= '0';
			aEqualb <= '1';			
		end if;	
	end process;
end Behavioral;

