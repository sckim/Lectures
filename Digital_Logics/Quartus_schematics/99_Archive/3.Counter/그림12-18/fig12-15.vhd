LIBRARY ieee;				     -----------------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-10 Glitch-Free Up-Counter --
							     -----------------------------------
ENTITY fig12_18 IS		     
	PORT(n_cp, U, D		: IN	std_logic;
		 Da, Db, Dc		: BUFFER std_logic);
END fig12_18;

ARCHITECTURE arc OF fig12_18 IS
BEGIN
	PROCESS (n_cp, U, D)
	BEGIN
		if n_cp'event and n_cp ='1' then		
			Da <= Da XOR (U and D);
			Db <= Db XOR ((U AND Da) OR (D AND NOT Da) );
			Dc <= Dc XOR ((U AND Db AND Da) OR (D AND Not Db AND Not Da) );
		end if;
	END PROCESS;
END arc;
