LIBRARY ieee;				 -------------------------------------------
USE ieee.std_logic_1164.ALL; -- State Machine Stepper Motor Sequencer --
							 -------------------------------------------
ENTITY ch14_1 IS
	PORT(clk, x	: IN	STD_LOGIC;
		 z		: OUT	STD_LOGIC);
END ch14_1 ;

ARCHITECTURE arc OF ch14_1 IS
	TYPE state_type IS (s0, s1, s2);
	SIGNAL state: state_type;
	SIGNAL s_z : STD_LOGIC;
BEGIN
	PROCESS (clk)
	BEGIN
		IF clk'EVENT AND clk = '1' THEN
			if x='1' then
				CASE state IS
					WHEN s0 => state <= s1;
						s_z <= '0';
					WHEN s1 => state <= s1;
						s_z <= '0';
					WHEN s2 => state <= s1;
						s_z <= '1';
				END CASE;
			else
				CASE state IS
					WHEN s0 => state <= s0;
						s_z <= '0';
					WHEN s1 => state <= s2;
						s_z <= '0';
					WHEN s2 => state <= s0;
						s_z <= '0';
				END CASE;
			end if;
		END IF;
	END PROCESS;
	z <= s_z;
END arc;

