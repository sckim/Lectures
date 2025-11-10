-- Digital Clock Logic
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY DigitalClock IS
	PORT(	reset					: in	std_logic;
			clk1hz				: in	std_logic;
			mode					: in	std_logic_vector(1 downto 0);
			set_pos				: in	std_logic_vector(2 downto 0);
			sw2					: in	std_logic;
		
			sec_out				: out	std_logic_vector(5 downto 0);
			min_out				: out	std_logic_vector(5 downto 0);
			hour_out				: out	std_logic_vector(4 downto 0));
END DigitalClock;

ARCHITECTURE Behavioral of DigitalClock IS
	signal	timeClock	: std_logic;
	signal	hour		: std_logic_vector(4 downto 0) := "00000";
	signal	min, sec	: std_logic_vector(5 downto 0) := "000000";

begin
-- process for clock source
	process(clk1hz, mode, sw2)
	begin
		if mode = "01" then			-- time set mode
			timeClock <= sw2;
		else
			timeClock <= clk1hz;
		end if;
	end process;

-- process for second
	process(reset, timeClock, sec)
	begin
		if reset = '0' then
			sec <= "000000";
		elsif rising_edge(timeClock) then
			if mode = "01" then				-- time set mode
				if set_pos = "001" then	-- second time set
					if conv_integer(sec) >= 59 then
						sec <= "000000";
					else
						sec <= sec + '1';
					end if;
				end if;
			else
				if conv_integer(sec) >= 59 then
					sec <= "000000";
				else
					sec <= sec + '1';
				end if;
			end if;
		end if;		
	end process;

-- process for minute
	process(reset, timeClock, sec, mode, set_pos)
	begin
		if reset = '0' then
			min <= "000000";
		elsif rising_edge(timeClock) then	
			if mode = "01" then				-- time set mode
				if set_pos = "010" then	-- minute time set
					if conv_integer(min) >= 59 then
						min <= "000000";
					else
						min <= min + '1';
					end if;
				end if;
			else		
				if conv_integer(sec) >= 59 then
					if conv_integer(min) >= 59 then
						min <= "000000";
					else
						min <= min + '1';
					end if;
				end if;	
			end if;	
		end if;
	end process;

-- process for hour
	process(reset, timeClock, min, mode, set_pos)
	begin
		if reset = '0' then
			hour <= "00000";
		elsif rising_edge(timeClock) then
			if mode = "01" then
				if set_pos = "100" then
					if conv_integer(hour) >= 23 then
						hour <= "00000";
					else
						hour <= hour + '1';
					end if;
				end if;
			else
				if conv_integer(sec) >= 59 then
					if conv_integer(min) >= 59 then
						if conv_integer(hour) >= 23 then
							hour <= "00000";
						else
							hour <= hour + '1';
						end if;
					end if;	
				end if;	
			end if;
		end if;		
	end process;	
	sec_out <= sec;
	min_out <= min;
	hour_out <= hour;
end Behavioral;



