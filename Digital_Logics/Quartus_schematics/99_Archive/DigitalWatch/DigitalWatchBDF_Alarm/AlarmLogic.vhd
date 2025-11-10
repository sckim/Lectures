-- Alarm Logic
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY AlarmLogic IS
	PORT(	reset					: in	std_logic;
			clk					: in	std_logic;
--			clk2hz				: in	std_logic;
			clk100hz				: in	std_logic;
			mode					: in	std_logic_vector(1 downto 0);
--			blink					: in	std_logic;
			set_pos				: in	std_logic_vector(2 downto 0);
		
			clk_sec, clk_min	: in	std_logic_vector(5 downto 0);
			clk_hour				: in	std_logic_vector(4 downto 0);
		
			sw2, sw3				: in	std_logic;
		
			sec_out				: out	std_logic_vector(5 downto 0);
			min_out				: out	std_logic_vector(5 downto 0);
			hour_out				: out	std_logic_vector(4 downto 0);
			alarm_out			: out	std_logic_vector(2 downto 0);
			alarm_on				: out	std_logic_vector(2 downto 0));
END AlarmLogic;

ARCHITECTURE  Behavioral of AlarmLogic IS
	signal	alarm			: std_logic	:= '0';
--	signal	AlarmClock	: std_logic := '0';
	signal	hour			: std_logic_vector(4 downto 0) := "00000";
	signal	min, sec		: std_logic_vector(5 downto 0) := "000000";

begin
-- process for Alarm on/off
	process(reset, alarm, sw3)
	begin
		if reset = '0' then
			alarm <= '0';
			alarm_on <= "000";
		elsif rising_edge(sw3) then
			if alarm = '0' then
				alarm <= '1';
				alarm_on <= "111";
			else
				alarm <= '0';
				alarm_on <= "000";
			end if;
		end if;	
	end process;
	
-- process for Alarm clock source
--	process(clk2hz, mode, blink, sw2)
--	begin
--		if mode = "10" then
--			if blink = '1' then
--				AlarmClock <= sw2;
--			else
--				AlarmClock <= clk2hz;
--			end if;
--		end if;
--	end process;

-- process for second
	process(reset, sw2, mode, set_pos)
	begin
		if reset = '0' then
			sec <= "000000";
		elsif rising_edge(sw2) then
			if mode = "10" and set_pos = "001" then	-- second alarm set
				if conv_integer(sec) >= 59 then
					sec <= "000000";
				else
					sec <= sec + '1';
				end if;
			end if;
		end if;		
	end process;

-- process for minute
	process(reset, sw2, mode, set_pos)
	begin
		if reset = '0' then
			min <= "000000";
		elsif rising_edge(sw2) then	
			if mode = "10" and set_pos = "010" then	-- minute alarm set
				if conv_integer(min) >= 59 then
					min <= "000000";
				else
					min <= min + '1';
				end if;
			end if;		
		end if;
	end process;

-- process for hour
	process(reset, sw2, mode, set_pos)
	begin
		if reset = '0' then
			hour <= "00000";
		elsif rising_edge(sw2) then
			if mode = "10" and set_pos = "100" then	-- minute alarm set
				if conv_integer(hour) >= 23 then
					hour <= "00000";
				else
					hour <= hour + '1';
				end if;
			end if;
		end if;		
	end process;	
	sec_out <= sec;
	min_out <= min;
	hour_out <= hour;
	
-- process for comparing between current time and alarm setting time	
	process(reset, clk100hz, mode, clk_hour, clk_min, hour, min, sec, alarm)
	begin
		if rising_edge(clk100hz) then
			if hour = clk_hour then
				if min = clk_min then
					if mode /= "10" and alarm = '1' then
						alarm_out <= "111";
					else
						alarm_out <= "000";
					end if;
				else
					alarm_out <= "000";
				end if;	
			else
				alarm_out <= "000";
			end if;
		end if;
	end process;	
end Behavioral;