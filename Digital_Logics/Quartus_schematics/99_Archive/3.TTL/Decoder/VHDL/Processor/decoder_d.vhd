LIBRARY ieee;				  -------------------------------
USE ieee.std_logic_1164.ALL;  -- Octal decoder with enable --
							  --  using IF-THEN-ELSE	   --
ENTITY decoder_d IS		      --  and CASE statement       --
	PORT(en	: IN    std_logic;-------------------------------
		 a	: IN	STD_LOGIC_VECTOR (2 downto 0);
		 y	: OUT	STD_LOGIC_VECTOR (7 downto 0));
END decoder_d;

ARCHITECTURE arc OF decoder_d IS
BEGIN
	PROCESS (a,en)
	BEGIN
		IF (en='1') THEN  
			CASE a IS
				WHEN "000" => y<="00000001";
				WHEN "001" => y<="00000010";
				WHEN "010" => y<="00000100";
				WHEN "011" => y<="00001000";
				WHEN "100" => y<="00010000";
				WHEN "101" => y<="00100000";
				WHEN "110" => y<="01000000";
				WHEN "111" => y<="10000000";
				WHEN others=> y<="00000000";
			END CASE;
		ELSE 
			y<="00000000";
		END IF;
	END PROCESS;
END arc;

