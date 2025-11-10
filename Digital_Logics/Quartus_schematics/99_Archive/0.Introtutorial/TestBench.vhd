library IEEE; 
use IEEE.std_logic_1164.all; 

entity BestBench is 
end BestBench; 

architecture BestBench of BestBench is 
	signal in_A,in_B : std_logic; 
	signal OUT_AND_2 : std_logic; 
	
	component AND_2 
		port ( A, B : in std_logic; 
			   OUT_AND2 : out std_logic ); 
	end component; 
 
begin 
	U0:AND_2 port map ( A => in_A, 
						B => in_B, 
						OUT_AND2 => OUT_AND_2 );
	process
	begin
	--	in_A <= ¡®0¡¯;
	--	in_B <= ¡®0¡¯; 
	--	wait for 100 ns;
		IN_A <= '1'; 
	--	wait for 100 ns;
		IN_A <= ¡®0¡¯;
		IN_B <= ¡®1¡¯;
		wait for 100 ns;
		IN_A <= ¡®1¡¯;
		wait; 
	end process; 
end; 

library IEEE; 
use IEEE.std_logic_1164.all; 

entity AND_2 is 
	port ( A, B : in std_logic; 
		   OUT_AND2 : out std_logic ); 
end AND_2; 

architecture AND_2 of AND_2 is 
begin
	OUT_AND2 <= A and B;
end AND_2; 