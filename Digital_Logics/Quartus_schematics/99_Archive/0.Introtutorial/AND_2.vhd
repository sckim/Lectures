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
