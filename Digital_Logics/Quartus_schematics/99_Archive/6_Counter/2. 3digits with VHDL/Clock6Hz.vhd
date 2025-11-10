LIBRARY ieee;			     -----------------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-100000 Glitch-Free Up-Counter --
		     -----------------------------------
ENTITY Clock6Hz IS		     
	PORT(n_cp	: IN	STD_LOGIC;
		 q		: BUFFER INTEGER RANGE 0 to 6 );
END Clock6Hz;

ARCHITECTURE arc OF Clock6Hz IS
BEGIN
	PROCESS (n_cp)
	BEGIN
		IF (n_cp'EVENT AND n_cp='0' ) THEN
			IF (q=5) THEN
				q <=0;
			ELSE 
				q <= q+1;
			END IF;
		END IF;
	END PROCESS;
END arc;