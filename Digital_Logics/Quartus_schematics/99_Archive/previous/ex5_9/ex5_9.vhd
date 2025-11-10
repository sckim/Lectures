LIBRARY ieee;			--VHDL Solution to Ex 5-9
USE ieee.std_logic_1164.ALL;

ENTITY ex5_9 IS
   	PORT(
        a,b,c		: IN std_logic;
        x			: OUT std_logic);
END ex5_9;

ARCHITECTURE arc OF ex5_9 IS
	BEGIN
  		x<=((a OR NOT b) AND (b OR c))AND b;
END arc;



