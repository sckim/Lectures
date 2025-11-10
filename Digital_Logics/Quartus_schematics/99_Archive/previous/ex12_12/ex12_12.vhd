LIBRARY ieee;				     -----------------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-10 Glitch-Free Up-Counter --
							     -----------------------------------
ENTITY ex12_12 IS		     
	PORT(n_cp, n_rd			: IN	std_logic;
		 q					: BUFFER integer RANGE 0 TO 7);
END ex12_12;

ARCHITECTURE arc OF ex12_12 IS
BEGIN
	PROCESS (n_cp, n_rd)
	BEGIN
		IF  (n_rd='0') THEN
			q<= 0;
			ELSIF (n_cp'EVENT AND n_cp='0' ) THEN
				IF (q=9) THEN
			      	q<=0;
			      	ELSE q<=q+1;
				END IF;
		END IF;
	END PROCESS;
END arc;

