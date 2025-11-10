LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fig4_13 IS
	PORT(
   		a, b: IN std_logic;
   		x: 	 OUT std_logic);
END fig4_13;

ARCHITECTURE arc OF fig4_13 IS
	BEGIN
		x<= (NOT(a XOR b) NOR ((NOT a) AND B));
END arc;

