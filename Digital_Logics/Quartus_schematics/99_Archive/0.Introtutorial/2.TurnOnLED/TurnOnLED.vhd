LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY TurnOnLED IS
	PORT ( SW : IN STD_LOGIC_VECTOR(0 to 17) ;
		   LEDR: OUT STD_LOGIC_VECTOR(0 to 17) ) ;
END TurnOnLED;

ARCHITECTURE LogicFunction OF TurnOnLED IS
BEGIN
	LEDR <= SW;
END LogicFunction ;