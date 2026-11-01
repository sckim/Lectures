LIBRARY ieee;					
USE ieee.std_logic_1164.ALL;	
								
ENTITY hazard IS					
	PORT(A,B,C	: IN 	std_logic;
		 F		: OUT	std_logic);
END hazard;	

ARCHITECTURE arc OF hazard IS	
	SIGNAL B1, D, E	: std_logic;
BEGIN
	B1 <= not B after 10ns;
	D <= A and B1 after 10ns;
	E <= B and C after 10ns;
	F <= D or E after 10ns;
END arc;