LIBRARY ieee;			 	---------------------
USE ieee.std_logic_1164.ALL; 	-- Parallel Binary --
					 	--  Comparator	   --
ENTITY ex6_9 IS			 	---------------------
   	PORT(
	    a			: IN std_logic_vector (3 DOWNTO 0);
		b			: IN std_logic_vector (3 DOWNTO 0);
		w			: OUT std_logic);
END ex6_9 ;

ARCHITECTURE arc OF ex6_9 IS	
BEGIN
 w<=(a(0) XNOR b(0)) AND (a(1) XNOR b(1)) AND
	(a(2) XNOR b(2)) AND (a(3) XNOR b(3));
END arc;
