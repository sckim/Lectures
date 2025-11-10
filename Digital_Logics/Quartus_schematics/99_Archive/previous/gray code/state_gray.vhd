
LIBRARY ieee;				 -------------------------------------
USE ieee.std_logic_1164.ALL; -- State Machine Gray Code Counter --
							 -------------------------------------
ENTITY state_gray IS
	PORT(clk	: IN	STD_LOGIC;
		LEDR	: OUT	STD_LOGIC_VECTOR(2 downto 0));
END state_gray ;

ARCHITECTURE arc OF state_gray IS
	TYPE state_type IS (s0, s1, s2, s3, s4, s5, s6, s7);
	SIGNAL state: state_type;
BEGIN
	PROCESS (clk)
	BEGIN
		IF clk'EVENT AND clk = '1' THEN
			CASE state IS
				WHEN s0 => state <= s1;
				WHEN s1 => state <= s2;
				WHEN s2 => state <= s3;
				WHEN s3 => state <= s4;
				WHEN s4 => state <= s5;
				WHEN s5 => state <= s6;
				WHEN s6 => state <= s7;
				WHEN s7 => state <= s0;
			END CASE;
		END IF;
	END PROCESS;

	WITH state SELECT
		LEDR <=	"000"	WHEN	s0,
				"001"	WHEN	s1,
				"011"	WHEN	s2,
				"010"	WHEN	s3,
				"110"	WHEN	s4,
				"111"	WHEN	s5,
				"101"	WHEN	s6,
				"100"	WHEN	s7;
END arc;

