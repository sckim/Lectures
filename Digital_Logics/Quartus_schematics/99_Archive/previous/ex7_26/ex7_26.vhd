-------------------------------------------------------------
-- 8-bit binary adder/subtractor using std_logic vectors   --
--  and the WHEN ELSE conditional signal assignment        --
-------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY ex7_26 IS
	PORT
	(
		add_sub			: IN 		std_logic;
		astring			: IN		std_logic_vector(7 DOWNTO 0);
		bstring			: IN		std_logic_vector(7 DOWNTO 0);
		result			: OUT   	std_logic_vector(7 DOWNTO 0)
	);
END ex7_26 ;

ARCHITECTURE arc OF ex7_26 IS
BEGIN
 	result<=astring+bstring WHEN add_sub='0'
 	   ELSE astring-bstring;
END arc;