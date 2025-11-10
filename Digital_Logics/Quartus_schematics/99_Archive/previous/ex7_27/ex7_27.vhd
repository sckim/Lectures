LIBRARY ieee;					   ---------------------------
USE ieee.std_logic_1164.ALL;	   -- BCD Correction Adder  --
USE ieee.std_logic_unsigned.ALL;   --  using IF-THEN-ELSE   --
								   ---------------------------
ENTITY ex7_27 IS
	PORT
	(
		astring			: IN		std_logic_vector(7 DOWNTO 0);
		bstring			: IN		std_logic_vector(7 DOWNTO 0);
		bcd_result		: OUT   	std_logic_vector(7 DOWNTO 0)
	);
END ex7_27 ;

ARCHITECTURE arc OF ex7_27 IS
	SIGNAL bin_result		:			std_logic_vector(7 DOWNTO 0);

BEGIN
	bin_result <= astring+bstring;
 	PROCESS (bin_result)
 	BEGIN
 		IF bin_result>"01001" 
 			THEN bcd_result<=bin_result+"0110";
 			ELSE bcd_result<=bin_result;
 		END IF;
 	END PROCESS;
END arc;


