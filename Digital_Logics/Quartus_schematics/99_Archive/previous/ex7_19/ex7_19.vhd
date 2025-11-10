LIBRARY ieee;					-----------------
USE ieee.std_logic_1164.ALL;	-- Full Adder  --
								-----------------
ENTITY ex7_19 IS
   	PORT(
        a1		: IN std_logic;
		b1		: IN std_logic;
		cin	 	: IN std_logic;		
		sum1	: OUT std_logic;
		cout	: OUT std_logic
		);					
END ex7_19 ;

ARCHITECTURE arc OF ex7_19 IS	
BEGIN
	cout<=(a1 AND b1) OR (a1 AND cin) OR (b1 AND cin);
	sum1<=(a1 XOR b1) XOR cin;
END arc;