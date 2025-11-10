LIBRARY ieee;				 -------------------------------------------
USE ieee.std_logic_1164.ALL; -- State Machine Stepper Motor Sequencer --
							 -------------------------------------------
ENTITY fig12_79 IS
	PORT(clk	: IN	STD_LOGIC;
		 q		: OUT	STD_LOGIC_VECTOR(3 downto 0));
END fig12_79;

ARCHITECTURE arc OF fig12_79 IS
	TYPE state_type IS (s0, s1, s2, s3);
	SIGNAL state: state_type;
BEGIN
	PROCESS (clk)
	BEGIN
		IF clk'EVENT AND clk = '1' THEN
			CASE state IS
				WHEN s0 => state <= s1;
				WHEN s1 => state <= s2;
				WHEN s2 => state <= s3;
				WHEN s3 => state <= s0;
			END CASE;
		END IF;
	END PROCESS;

	WITH state SELECT
		q 	<=	"0001"	WHEN	s0,
				"0010"  WHEN	s1,
				"0100"	WHEN	s2,
				"1000"	WHEN	s3;
	END arc;


