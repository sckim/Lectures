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

