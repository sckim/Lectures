LIBRARY ieee;			     -----------------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-100000 Glitch-Free Up-Counter --
		     -----------------------------------
ENTITY Clock1Hz IS		     
	PORT(n_cp, n_rd		: IN	STD_LOGIC;
		 q				: BUFFER INTEGER RANGE 0 to 50000000 );
END Clock1Hz;

ARCHITECTURE arc OF Clock1Hz IS
BEGIN
	PROCESS (n_cp, n_rd)
	BEGIN
		IF  (n_rd='0') THEN
			q <= 0;
		ELSIF (n_cp'EVENT AND n_cp='0' ) THEN
			IF (q=49999999) THEN
		      q <=0;
			ELSE 
				q <= q+1;
			END IF;
		END IF;
	END PROCESS;
END arc;