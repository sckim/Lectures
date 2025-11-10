-- mode selection by switch 0
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY FNDDisplay IS
	PORT(	reset							: in	std_logic;
			clk, clk2hz, clk100hz	: in	std_logic;
			sw2							: in	std_logic;
			mode							: in	std_logic_vector(1 downto 0);
			set_pos						: in	std_logic_vector(2 downto 0);
			dc_sec, dc_min				: in	std_logic_vector(5 downto 0);
			dc_hour						: in	std_logic_vector(4 downto 0);
			tl_mmsec						: in 	std_logic_vector(6 downto 0);
			tl_sec, tl_min				: in	std_logic_vector(5 downto 0);
			al_sec, al_min				: in	std_logic_vector(5 downto 0);
			al_hour						: in	std_logic_vector(4 downto 0);

			hourFND, minFND, secFND		: out	std_logic_vector(6 downto 0);
			hourFNDSel2, hourFNDSel1	: out	std_logic;	
			minFNDSel2, minFNDSel1		: out	std_logic;	
			secFNDSel2, secFNDSel1		: out	std_logic;
			blink_out						: out std_logic);
END FNDDisplay;

ARCHITECTURE Behavioral of FNDDisplay IS
	signal	hour10, hour0			: integer := 0;
	signal	min10, min0				: integer := 0;
	signal	sec10, sec0				: integer := 0;
	signal	FNDhour10, FNDhour0	: std_logic_vector(6 downto 0) :="0000000";
	signal	FNDmin10, FNDmin0		: std_logic_vector(6 downto 0) :="0000000";
	signal	FNDsec10, FNDsec0		: std_logic_vector(6 downto 0) :="0000000";
	signal	blink						: std_logic	:= '1'; -- this signal indicate blink operation on
	signal	disp_sec, disp_min, disp_hour	: std_logic	:= '1'; -- this signal blink synchronized with clk2hz
	
	type state_type is (s0, s1, s2, s3);
	signal	state						: state_type;

	begin
-- process for 7-segment blink on/off
	process(reset, clk2hz, mode, blink, sw2)
	begin
		if reset = '0' then
			blink <= '1';
		elsif rising_edge(clk2hz) then
			case state is 
				when s0 =>
					if mode = "01" or mode = "10" then 	-- time set or alarm set mode
						if sw2 = '1' then
							state <= s1;
							blink <= '1';
						else
							state <= s0;
							blink <= '1';
						end if;
					else
						state <= s0;
						blink <= '1';
					end if;
				when s1 =>
					if mode = "01" or mode = "10" then
						if sw2 = '1' then
							state <= s2;
							blink <= '1';
						else
							state <= s0;
							blink <= '1';
						end if;
					else
						state <= s0;
						blink <= '1';
					end if;
				when s2 =>
					if mode = "01" or mode = "10" then
						if sw2 = '1' then
							state <= s3;
							blink <= '1';
						else
							state <= s0;
							blink <= '1';
						end if;
					else
						state <= s0;
						blink <= '1';
					end if;
				when s3 =>
					if mode = "01" or mode = "10" then
						if sw2 = '1' then
							state <= s3;
							blink <= '0';
						else
							state <= s0;
							blink <= '1';
						end if;
					else
						state <= s0;
						blink <= '1';
					end if;
			end case;	
		end if;
		blink_out <= blink;		
	end process;

-- process for display on/off
	process(clk2hz, mode, set_pos, blink, disp_hour, disp_min, disp_sec)
	begin
		if rising_edge(clk2hz) then
			if mode = "01" or mode = "10" then
				if blink = '1' then 
					case set_pos is
						when "100" => 
							disp_hour <= not disp_hour;
							disp_min <= '1';
							disp_sec <= '1';
						when "010" => 
							disp_hour <= '1';
							disp_min <= not disp_min;
							disp_sec <= '1';
						when "001" => 
							disp_hour <= '1';
							disp_min <= '1';
							disp_sec <= not disp_sec;
						when others => null;
					end case;
				else
					disp_hour <= '1';
					disp_min <= '1';
					disp_sec <= '1';
				end if;	
			else
				disp_hour <= '1';
				disp_min <= '1';
				disp_sec <= '1';
			end if;
		end if;		
	end process;
	
	
-- process for converting to integer
	process(mode, dc_hour, dc_min, dc_sec, tl_min, tl_sec, tl_mmsec, al_hour, al_min, al_sec)
	begin
		case mode is
			when "00" | "01" =>	-- digital clock, clock setting
				hour10 <= conv_integer(dc_hour)/10;
				hour0 <= conv_integer(dc_hour) mod 10;
				min10 <= conv_integer(dc_min)/10;
				min0 <= conv_integer(dc_min) mod 10;
				sec10 <= conv_integer(dc_sec)/10;
				sec0 <= conv_integer(dc_sec) mod 10;

				when "10" =>	-- alarm mode
				hour10 <= conv_integer(al_hour)/10;
				hour0 <= conv_integer(al_hour) mod 10;
				min10 <= conv_integer(al_min)/10;
				min0 <= conv_integer(al_min) mod 10;
				sec10 <= conv_integer(al_sec)/10;
				sec0 <= conv_integer(al_sec) mod 10;
				
			when "11" =>	-- timer mode
				hour10 <= conv_integer(tl_min)/10;
				hour0 <= conv_integer(tl_min) mod 10;
				min10 <= conv_integer(tl_sec)/10;
				min0 <= conv_integer(tl_sec) mod 10;
				sec10 <= conv_integer(tl_mmsec)/10;
				sec0 <= conv_integer(tl_mmsec) mod 10;
			when others => null;	
		end case;
	end process;	

--	process for 7-segment FND display	
	process(clk, hour10, hour0, min10, min0, sec10, sec0, disp_hour, disp_min, disp_sec)
	begin
		if rising_edge(clk) then
			if disp_hour = '1' then
				case hour10 is           --abcdefg-
					when 0 => FNDhour10 <= "1111110";
					when 1 => FNDhour10 <= "0110000";
					when 2 => FNDhour10 <= "1101101";
					when others => null;
				end case;
		
				case hour0 is            --abcdefg-
					when 0 => FNDhour0 <= "1111110";
					when 1 => FNDhour0 <= "0110000";
					when 2 => FNDhour0 <= "1101101";
					when 3 => FNDhour0 <= "1111001";
					when 4 => FNDhour0 <= "0110011";
					when 5 => FNDhour0 <= "1011011";
					when 6 => FNDhour0 <= "1011111";
					when 7 => FNDhour0 <= "1110000";
					when 8 => FNDhour0 <= "1111111";
					when 9 => FNDhour0 <= "1110011";
					when others => null;
				end case;
			else
				FNDhour10 <= "0000000";
				FNDhour0 <= "0000000";
			end if;
		end if;	
			
		if rising_edge(clk) then
			if disp_min ='1' then 
				case min10 is           --abcdefg-
					when 0 => FNDmin10 <= "1111110";
					when 1 => FNDmin10 <= "0110000";
					when 2 => FNDmin10 <= "1101101";
					when 3 => FNDmin10 <= "1111001";
					when 4 => FNDmin10 <= "0110011";
					when 5 => FNDmin10 <= "1011011";
					when others => null;
				end case;
			
				case min0 is         --abcdefg-
					when 0 => FNDmin0 <= "1111110";
					when 1 => FNDmin0 <= "0110000";
					when 2 => FNDmin0 <= "1101101";
					when 3 => FNDmin0 <= "1111001";
					when 4 => FNDmin0 <= "0110011";
					when 5 => FNDmin0 <= "1011011";
					when 6 => FNDmin0 <= "1011111";
					when 7 => FNDmin0 <= "1110000";
					when 8 => FNDmin0 <= "1111111";
					when 9 => FNDmin0 <= "1110011";
					when others => null;
				end case;
			else
				FNDmin10 <= "0000000";
				FNDmin0 <= "0000000";
			end if;
		end if;	

		if rising_edge(clk) then
			if disp_sec ='1' then 
				case sec10 is         --abcdefg-
					when 0 => FNDsec10 <= "1111110";
					when 1 => FNDsec10 <= "0110000";
					when 2 => FNDsec10 <= "1101101";
					when 3 => FNDsec10 <= "1111001";
					when 4 => FNDsec10 <= "0110011";
					when 5 => FNDsec10 <= "1011011";
					when others => null;
				end case;

				case sec0 is         --abcdefg-
					when 0 => FNDsec0 <= "1111110";
					when 1 => FNDsec0 <= "0110000";
					when 2 => FNDsec0 <= "1101101";
					when 3 => FNDsec0 <= "1111001";
					when 4 => FNDsec0 <= "0110011";
					when 5 => FNDsec0 <= "1011011";
					when 6 => FNDsec0 <= "1011111";
					when 7 => FNDsec0 <= "1110000";
					when 8 => FNDsec0 <= "1111111";
					when 9 => FNDsec0 <= "1110011";
					when others => null;
				end case;
			else
				FNDsec10 <= "0000000";
				FNDsec0 <= "0000000";
			end if;
		end if;	
	end process;
	
	process(clk100hz, FNDhour10, FNDhour0, FNDmin10, FNDmin0, FNDsec10, FNDsec0)
	begin
		if (clk100hz = '1') then
			hourFNDSel1 <= '0';
			hourFNDSel2 <= '1';
			hourFND <= FNDhour0;
			minFNDSel1 <= '0';
			minFNDSel2 <= '1';
			minFND <= FNDmin0;
			secFNDSel1 <= '0';
			secFNDSel2 <= '1';
			secFND <= FNDsec0;
		else	
			hourFNDSel1 <= '1';
			hourFNDSel2 <= '0';
			hourFND <= FNDhour10;
			minFNDSel1 <= '1';
			minFNDSel2 <= '0';
			minFND <= FNDmin10;
			secFNDSel1 <= '1';
			secFNDSel2 <= '0';
			secFND <= FNDsec10;
		end if;
	end process;	
end Behavioral;