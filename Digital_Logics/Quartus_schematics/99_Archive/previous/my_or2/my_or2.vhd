LIBRARY IEEE;
USE		IEEE.std_logic_1164.all;

ENTITY my_or2 IS
	PORT
	(
		a, b	: IN	bit_vector(1 DOWNTO 0);
		equal	: OUT	STD_LOGIC
	);
END my_or2;

ARCHITECTURE sample OF my_or2 IS
	SIGNAL x: bit_vector(1 downto 0);
	COMPONENT xnor2
	PORT
	(
		in1, in2		: IN	STD_LOGIC;
		out1	: OUT	STD_LOGIC
	);
	
	out1 <= in1 XNOR in2;
END COMPONENT;
	COMPONENT and2
	PORT
	(
		in1, in2		: IN	STD_LOGIC;
		out1	: OUT	STD_LOGIC
	);
	out1 <= in1 AND in2;
END COMPONENT;

BEGIN
	V1 : xnor2;
	
	PORT MAP (a(1), b(1), x(1));
	
	V2 : xnor2;
	PORT MAP (a(0), b(0), x(0));
	
	V3 : and2;
	
	PORT MAP (x(0), x(1), equal);
END sample;