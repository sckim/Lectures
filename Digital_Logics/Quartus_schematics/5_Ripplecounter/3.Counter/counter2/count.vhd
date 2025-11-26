library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity count is
	port(clk : in std_logic ;
		 count : buffer std_logic_vector(3 downto 0));
end count;

architecture sample of count is
begin
	process(clk)
	begin 
		if (clk'event and clk='1') then
		count <= count+1;
		end if;
	end process;
end sample;