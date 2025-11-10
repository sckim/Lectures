LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY simplify IS
	PORT(
		a, b, c, d: IN std_logic;
		x:    	OUT std_logic);
	END simplify;

ARCHITECTURE arc OF simplify IS
BEGIN
	x <= (NOT a AND NOT b AND NOT c AND d) OR 
	     (NOT a AND NOT b AND c AND d) OR
		 (NOT a AND b AND NOT c AND d) OR
         (NOT a AND b AND c AND d) OR
         (a AND b AND c AND d) OR
         (a AND NOT b AND c AND d);
END arc;

