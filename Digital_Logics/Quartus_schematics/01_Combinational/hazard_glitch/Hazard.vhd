LIBRARY ieee;						------------------------------
USE ieee.std_logic_1164.ALL;		-- BCD to 7 Segment Decoder --
									------------------------------
ENTITY hazard IS					
	PORT(A,B,C		: IN 	std_logic;
		 F,G	: OUT	std_logic);
END hazard;	

ARCHITECTURE arc OF hazard IS	
	SIGNAL G1, D, E	: std_logic;
BEGIN
	G1 <= A and B after 20ns;
	G <= G1;
	F <= G1 xnor C after 20ns;
END arc;