library ieee;
use ieee.std_logic_1164.all;

package my_package is
	constant width			: integer:=4;
end my_package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.my_package.all;

entity nBitAddSub1 is
	port(	a, b 							: in integer range 0 to 2**width-1;
			m								: in std_logic;
			sum							: out std_logic_vector(width+1 downto 0));
end nBitAddSub1;

architecture Behavioral of nBitAddSub1 is
begin
	process(m, a, b)
	begin
		if (m = '0') then 
			sum <= conv_std_logic_vector(a+b, width+2);	
		else 
			sum <= conv_std_logic_vector(a-b, width+2);	
		end if;
	end process;
end Behavioral;

