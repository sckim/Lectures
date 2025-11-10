LIBRARY ieee;				 ------------------------------
USE ieee.std_logic_1164.all; -- 4-bit Binary Adder using --
							 --  Integer Arithmetic      --
ENTITY halfadder IS			 	 ------------------------------
	PORT( A0, B0	: IN	std_logic;
		  Sum, Carry: OUT	std_logic);
END halfadder;

ARCHITECTURE arc OF halfadder IS
BEGIN	
	Sum <= A0 XOR B0;
	Carry <= A0 AND B0;
END arc;