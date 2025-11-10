library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SimpleGates is
     port(A, B, C, D	: in std_logic;
			 Y				: out std_logic);
end SimpleGates;

architecture Behavioral of SimpleGates is
begin
     Y <= (A nor B) and (C nand D);
end Behavioral;