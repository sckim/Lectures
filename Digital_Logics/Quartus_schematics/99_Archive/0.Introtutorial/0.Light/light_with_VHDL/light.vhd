LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY light IS
	PORT ( a, b, c : IN STD_LOGIC ;
	       f : OUT STD_LOGIC ) ;
END light ;

ARCHITECTURE LogicFunction OF light IS
BEGIN
	-- f <= (x1 AND NOT x2) OR (NOT x1 AND x2);
	f <= (not(a) and b and c) or (a and not(b)) or (a and b);
END LogicFunction ;