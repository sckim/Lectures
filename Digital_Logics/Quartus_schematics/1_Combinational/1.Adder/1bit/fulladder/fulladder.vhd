LIBRARY ieee;				 ------------------------------
USE ieee.std_logic_1164.all; -- 4-bit Binary Adder using --
							 --  Integer Arithmetic      --
ENTITY fulladder IS			 ------------------------------
	PORT( A, B, Cin	: IN	std_logic;
		  S, Cout	: OUT	std_logic);
END fulladder;

ARCHITECTURE arc OF fulladder IS
BEGIN	
	S  <= A XOR B XOR Cin;
	Cout <= (A AND B) OR (B AND Cin) OR (A AND Cin);
END arc;