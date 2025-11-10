LIBRARY ieee;				 --------------------------
USE ieee.std_logic_1164.ALL; -- Controlled Inverter  --
							 -- using a FOR LOOP     --
ENTITY ex6_10 IS			 -- within a PROCESS     --
   	PORT(					 --------------------------
        c			: IN std_logic;
		d			: IN std_logic_vector (3 DOWNTO 0);
		x			: OUT std_logic_vector (3 DOWNTO 0));  							
END ex6_10;

ARCHITECTURE arc OF ex6_10 IS	
BEGIN
	PROCESS 
	BEGIN
		FOR i IN 3 DOWNTO 0	LOOP
    		x(i)<=d(i) XOR c;
		END LOOP ;
	END PROCESS;
END arc;
