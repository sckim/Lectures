-- mode selection by switch 0
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY FNDDisplay IS
	PORT(	clk, clk100hz			: in	std_logic;
			mode						: in	std_logic_vector(1 downto 0);
			dc_sec, dc_min			: in	std_logic_vector(5 downto 0);
			dc_hour					: in	std_logic_vector(4 downto 0);
			tl_mmsec					: in 	std_logic_vector(6 downto 0);
			tl_sec, tl_min			: in	std_logic_vector(5 downto 0);
		
			hourFND, minFND, secFND		: out	std_logic_vector(6 downto 0);
			hourFNDSel2, hourFNDSel1	: out	std_logic;	
			minFNDSel2, minFNDSel1		: out	std_logic;	
			secFNDSel2, secFNDSel1		: out	std_logic);
END FNDDisplay;

ARCHITECTURE Behavioral of FNDDisplay IS
	signal	hour10, hour0			: integer := 0;
	signal	min10, min0				: integer := 0;
	signal	sec10, sec0				: integer := 0;
	signal	FNDhour10, FNDhour0	: std_logic_vector(6 downto 0) :="0000000";
	signal	FNDmin10, FNDmin0		: std_logic_vector(6 downto 0) :="0000000";
	signal	FNDsec10, FNDsec0		: std_logic_vector(6 downto 0) :="0000000";	

begin
-- process for converting to integer
	process(mode, dc_hour, dc_min, dc_sec, tl_min, tl_sec, tl_mmsec)
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
				hour10 <= conv_integer(dc_hour)/10;
				hour0 <= conv_integer(dc_hour) mod 10;
				min10 <= conv_integer(dc_min)/10;
				min0 <= conv_integer(dc_min) mod 10;
				sec10 <= conv_integer(dc_sec)/10;
				sec0 <= conv_integer(dc_sec) mod 10;
				
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
	process(clk, hour10, hour0, min10, min0, sec10, sec0)
	begin
		if rising_edge(clk) then
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