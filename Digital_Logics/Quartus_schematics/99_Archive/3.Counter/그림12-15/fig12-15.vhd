LIBRARY ieee;				     -----------------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-10 Glitch-Free Up-Counter --
							     -----------------------------------
ENTITY fig12_15 IS		     
	PORT(n_cp			: IN	std_logic;
		 Da, Db, Dc		: BUFFER std_logic);
END fig12_15;

ARCHITECTURE arc OF fig12_15 IS
BEGIN
	PROCESS (n_cp)
	BEGIN
		if n_cp'event and n_cp ='1' then
			Da <= Not Da;
			Db <= Db XOR Da;
			Dc <= Dc XOR ( Db AND Da);
		end if;
	END PROCESS;
END arc;
