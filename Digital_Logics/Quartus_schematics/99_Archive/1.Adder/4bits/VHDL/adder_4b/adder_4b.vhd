LIBRARY ieee;				 ------------------------------
USE ieee.std_logic_1164.all; -- 4-bit Binary Adder using --
							 --  Integer Arithmetic      --
ENTITY adder_4b IS			 ------------------------------
	PORT
	(
		cin				: IN 		integer RANGE 0 TO 1;
		astring			: IN		integer RANGE 0 TO 15;
		bstring			: IN		integer RANGE 0 TO 15;
		sum_string		: OUT   	integer RANGE 0 TO 31
	);
END adder_4b ;

ARCHITECTURE arc OF adder_4b IS
BEGIN	
	sum_string<=astring+bstring+cin;	
END arc;