library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity RegisterInference is
	port(	d, clk, clr, pre, load, data	: in std_logic;
			q1, q2							: out std_logic);
end RegisterInference;

architecture design of RegisterInference is
begin

	process(clk, load, data)                      
	begin
	    if load = '1' then  			 
	        q1 <= data;
	    elsif rising_edge(clk) THEN
	        q1 <= d;
	    end if;
	end process;
	
	process(clk, clr, pre)
	begin
		if (clr = '0') then
	        q2 <= '0';
		elsif (pre = '0') then  			 
	        q2 <= '1';
		elsif rising_edge(clk) then
				q2 <= d;
		end if;
	end process;
end design;