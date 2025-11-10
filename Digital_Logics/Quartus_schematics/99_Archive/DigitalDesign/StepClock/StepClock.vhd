library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity StepClock is
	port(	rst				: in	std_logic;
			clk				: IN	std_logic;
			stepSwitch		: in	std_logic;
			stepPulse		: out	std_logic);
end StepClock;

architecture Behavioral of StepClock is
	type STATE_TYPE is (s0, s1);
	signal state	: STATE_TYPE;
	signal clk1Hz		: std_logic;	
begin
	process(clk)
		variable  m 			: integer := 0;
	begin
		if rising_edge(clk) then
			if m >= 499999 then -- 1Hz clock
				m := 0;
				clk1Hz <= not clk1Hz;
			else
				m := m + 1;
			end if;
		end if;
	end process; 

	process(rst, clk1Hz)
	begin
		if rst = '0' then
			state <= s0;
		elsif rising_edge(clk1Hz) then
			case state is 
				when s0 => 
					if stepSwitch = '1' then
						state <= s1;
						stepPulse <= '1';
					else 
						state <= s0;
					end if;
				when s1 =>
					if stepSwitch = '1' then
						state <= s1;
						stepPulse <= '0';
					else
						state <= s0;
						stepPulse <= '0';
					end if;
			end case;
		end if;
	end process;
end Behavioral;