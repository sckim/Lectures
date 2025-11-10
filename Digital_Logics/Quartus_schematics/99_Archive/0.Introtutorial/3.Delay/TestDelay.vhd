LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY TestDelay IS
	PORT ( MYsignal : OUT BIT
			) ;
END ENTITY TestDelay;

ARCHITECTURE LogicFunction OF TestDelay IS
BEGIN
	MYsignal <= '1',                           -- start with '0'
				'1' AFTER 100 ns,     -- and toggle after
                '0' after 100 ns,         -- every 10 ns
                '1' afTer 100 ns;
END ARCHITECTURE LogicFunction ;