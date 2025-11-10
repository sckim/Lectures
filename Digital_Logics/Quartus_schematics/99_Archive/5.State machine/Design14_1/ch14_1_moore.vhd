LIBRARY ieee;				 -------------------------------------------
USE ieee.std_logic_1164.ALL; -- State Machine Stepper Motor Sequencer --
							 -------------------------------------------
ENTITY ch14_1_moore IS
	PORT(clk, x	: IN	STD_LOGIC;
		 z		: OUT	STD_LOGIC);
END ch14_1_moore ;

ARCHITECTURE arc OF ch14_1_moore IS
	TYPE state_type IS (s0, s1, s2, s3);
	SIGNAL state: state_type;
BEGIN
	PROCESS (clk)
	BEGIN
		IF clk'EVENT AND clk = '1' THEN
			if x='1' then
				CASE state IS
					WHEN s0 => state <= s1;
					WHEN s1 => state <= s1;
					WHEN s2 => state <= s3;
					WHEN s3 => state <= s1;
				END CASE;
			else
				CASE state IS
					WHEN s0 => state <= s0;
					WHEN s1 => state <= s2;
					WHEN s2 => state <= s0;
					WHEN s3 => state <= s2;
				END CASE;
			end if;
		END IF;
	END PROCESS;
	WITH state SELECT
		z 	<=	'0'	WHEN	s0,
				'0' WHEN	s1,
				'0'	WHEN	s2,
				'1' WHEN	s3;
END arc;

