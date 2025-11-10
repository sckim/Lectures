-- Timer Logic
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY TimerLogic IS
	PORT(	reset					: in	std_logic;
			mode					: in	std_logic_vector(1 downto 0);
			clk100hz				: in	std_logic;
			sw1, sw2				: in	std_logic;
		
			mmsec_out			: out	std_logic_vector(6 downto 0);
			sec_out				: out	std_logic_vector(5 downto 0);
			min_out				: out	std_logic_vector(5 downto 0));
END TimerLogic;

ARCHITECTURE Behavioral of TimerLogic IS
	signal	mmsec		: std_logic_vector(6 downto 0) := "0000000";
	signal	min		: std_logic_vector(5 downto 0) := "000000";
	signal	sec		: std_logic_vector(5 downto 0) := "000000";
	signal 	state		: std_logic;	-- 0 : stop state, 1 : up count state
	signal	k			: std_logic_vector(3 downto 0) := "0000";
begin

-- process for state control
	process(reset, mode, sw1)
	begin
		if reset = '0' then
			state <= '0';	-- stop state
		elsif falling_edge(sw1) then
			if mode = "11" then
				state <= not state;
			end if;
		end if;		
	end process;
	
-- process for 1/100 second
	k <= state & mode & sw2;
	process(reset, clk100hz, k)
	begin
		if reset ='0' then
			mmsec <= "0000000";
		elsif rising_edge(clk100hz) then
			case k is 
				when "0111" => mmsec <= "0000000";
				when "1000"|"1001"|"1010"|"1011"|"1100"|"1101"|"1110"|"1111" =>
					if conv_integer(mmsec) >= 99 then
						mmsec <= "0000000";
					else 
						mmsec <= mmsec + '1';
					end if;
				when others => null;
			end case;
		end if;	
	end process;

-- process for second
	process(reset, clk100hz, mmsec, k)
	begin
		if reset ='0' then
			sec <= "000000";
		elsif rising_edge(clk100hz) then
			case k is 
				when "0111" => sec <= "000000";
				when "1000"|"1001"|"1010"|"1011"|"1100"|"1101"|"1110"|"1111" =>
					if conv_integer(mmsec) >= 99 then
						if conv_integer(sec) >= 59 then
							sec <= "000000";
						else
							sec <= sec + '1';
						end if;
					end if;	
				when others => null;
			end case;
		end if;	
	end process;
	
-- process for min
	process(reset, clk100hz, mmsec, sec, k)
	begin
		if reset ='0' then
			min <= "000000";
		elsif rising_edge(clk100hz) then
			case k is 
				when "0111" => min <= "000000";
				when "1000"|"1001"|"1010"|"1011"|"1100"|"1101"|"1110"|"1111" =>
					if conv_integer(mmsec) >= 99 then
						if conv_integer(sec) >= 59 then
							if conv_integer(min) >= 59 then
								min <= "000000";
							else
								min <= min + '1';
							end if;	
						end if;
					end if;	
				when others => null;
			end case;
		end if;	
	end process;
	mmsec_out <= mmsec;
	sec_out <= sec;
	min_out <= min;
end Behavioral;