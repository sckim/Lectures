
LIBRARY ieee;				 -------------------------------------------
USE ieee.std_logic_1164.ALL; -- State Machine Stepper Motor Sequencer --
							 --   with Direction Control			  --
ENTITY state_stepper_a IS    -------------------------------------------
	PORT(clk, dir	: IN	STD_LOGIC;
		 q			: OUT	STD_LOGIC_VECTOR(3 downto 0));
END state_stepper_a ;

ARCHITECTURE arc OF state_stepper_a IS
	TYPE state_type IS (s0, s1, s2, s3);
	SIGNAL state: state_type;
BEGIN
	PROCESS (clk)
	BEGIN
		IF clk'EVENT AND clk = '1' THEN
			IF dir='1' THEN		-- Clockwise Steps
				CASE state IS
					WHEN s0 => state <= s1;
					WHEN s1 => state <= s2;
					WHEN s2 => state <= s3;
					WHEN s3 => state <= s0;
				END CASE;
			ELSE				-- Counter-clockwise Steps
				CASE state IS
					WHEN s0 => state <= s3;
					WHEN s1 => state <= s0;
					WHEN s2 => state <= s1;
					WHEN s3 => state <= s2;
				END CASE;
			END IF;
		END IF;
	END PROCESS;

	WITH state SELECT
		q 	<=	"0001"	WHEN	s0,
				"0010"  WHEN	s1,
				"0100"	WHEN	s2,
				"1000"	WHEN	s3;
	END arc;


