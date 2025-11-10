LIBRARY ieee;				     -----------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-16 Up-Counter       --
							     -----------------------------
ENTITY Cnt16up IS		     
	PORT( n_cp, n_rd			: IN	std_logic;
		  q					: BUFFER integer RANGE 0 TO 15);
END Cnt16up;

ARCHITECTURE arc OF Cnt16up IS
	COPONENT
BEGIN

END

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Bin2Seg IS
	PORT(SW 	: IN std_logic_vector(3 DOWNTO 0);
		 HEX0	: OUT std_logic_vector(0 TO 6));
END Bin2Seg;

ARCHITECTURE arc OF Bin2Seg IS
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
				"0001000" WHEN "1010",	-- A
				"1100000" WHEN "1011",	-- B
				"0110001" WHEN "1100",	-- C
				"1000010" WHEN "1101",	-- D
				"0110000" WHEN "1110",	-- E
				"0111000" WHEN "1111",	-- F				
				"1111111" WHEN OTHERS;
END arc;

						   						   
LIBRARY ieee;				     -----------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-16 Up-Counter       --
							     -----------------------------
ENTITY mod16up IS		     
	PORT(n_cp, n_rd			: IN	std_logic;
		 q					: BUFFER integer RANGE 0 TO 15);
END mod16up;

ARCHITECTURE arc OF mod16up IS
BEGIN
	PROCESS (n_cp, n_rd)
	BEGIN
		IF  (n_rd='0') THEN
			q <= 0;
			ELSIF (n_cp'EVENT AND n_cp='0') THEN
			      q <=q+1;
		END IF;
	END PROCESS;
END arc;

