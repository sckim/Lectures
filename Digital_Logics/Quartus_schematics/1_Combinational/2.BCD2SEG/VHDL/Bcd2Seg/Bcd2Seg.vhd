LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Bcd2Seg IS
	PORT(SW 	: IN std_logic_vector(3 DOWNTO 0);
		 HEX0	: OUT std_logic_vector(0 TO 6));
END Bcd2Seg;

ARCHITECTURE arc OF Bcd2Seg IS
BEGIN 
	WITH SW SELECT
		HEX0 <= "0000001" WHEN "0000",	-- 0
				"1001111" WHEN "0001",	-- 1
				"0010010" WHEN "0010",	-- 2
				"0000110" WHEN "0011",	-- 3
				"1001100" WHEN "0100",	-- 4
				"0100100" WHEN "0101",	-- 5
				"0100000" WHEN "0110",	-- 6
				"0001111" WHEN "0111",	-- 7
				"0000000" WHEN "1000",	-- 8
				"0001100" WHEN "1001",	-- 9
				"1111111" WHEN OTHERS;
END arc;

						   