library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity simple_counter is
    Port ( 
		clock: in  STD_LOGIC;
		counter_out : out unsigned(31 downto 0)
		);
end entity simple_counter;

architecture logic of simple_counter is
begin
	process(clock)
		variable counter_var: unsigned(31 downto 0);
		begin 
			if rising_edge(clock) then
				counter_var := counter_var + 1;
			end if;
		counter_out <= counter_var;		
	end process;
end architecture;


