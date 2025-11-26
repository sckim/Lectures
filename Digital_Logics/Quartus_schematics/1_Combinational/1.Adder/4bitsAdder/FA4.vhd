LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FA4 IS 
	PORT (	SW	: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			LEDR 	: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			LEDG 	: OUT	STD_LOGIC_VECTOR(4 DOWNTO 0));
END FA4;

ARCHITECTURE Structure OF FA4 IS
	COMPONENT fa
		PORT (	a, b, ci	: IN 	STD_LOGIC;
				s, co 	: OUT STD_LOGIC);
	END COMPONENT;
	SIGNAL A, B, S : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL C : STD_LOGIC_VECTOR(4 DOWNTO 1);
BEGIN
	A <= SW(7 DOWNTO 4);
	B <= SW(3 DOWNTO 0);

	bit0: fa PORT MAP (A(0), B(0), '0', S(0), C(1));
	bit1: fa PORT MAP (A(1), B(1), C(1), S(1), C(2));
	bit2: fa PORT MAP (A(2), B(2), C(2), S(2), C(3));
	bit3: fa PORT MAP (A(3), B(3), C(3), S(3), C(4));
	
	-- Display the inputs
	LEDR <= SW;
	LEDG <= (C(4) & S);
END Structure;
			

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY fa IS
	PORT (	a, b, ci	: IN 	STD_LOGIC;
			s, co 	: OUT STD_LOGIC);
END fa;

ARCHITECTURE Structure OF fa IS
--	SIGNAL a_xor_b : STD_LOGIC;
BEGIN
	--a_xor_b <= a XOR b;
	--s <= a_xor_b XOR ci;
	--co <= (NOT(a_xor_b) AND b) OR (a_xor_b AND ci);

	s <= a XOR b XOR ci;
	--co <= (NOT(a XOR b) AND b) OR ((a XOR b) AND ci);
	co <= (a and b) or (a and ci) or (b and ci);
END Structure;
