library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY MasterSelect IS
	PORT(	reset								: in	std_logic;
			clk 								: in	std_logic;
			sw0, sw1							: in	std_logic;
			clk1hz_out, clk2hz_out		: out	std_logic;
			mode_out							: out	std_logic_vector(1 downto 0);
			set_pos_out						: out	std_logic_vector(2 downto 0);
			clk100hz_out					: out std_logic);
END MasterSelect;

ARCHITECTURE Behavioral of MasterSelect IS
	signal	clk1hz, clk2hz, clk100hz	: std_logic;
	signal	mode								: std_logic_vector(1 downto 0)	:= "00";
	signal	set_pos							: std_logic_vector(2 downto 0)	:= "100";
	signal	nsw0, nnsw0						: std_logic;
	
BEGIN
-- 1Hz clock generation
	process(clk, clk1hz)
	variable		cnt1hz		: 	integer := 0;
	begin
		if rising_edge(clk) then
			if cnt1hz >= 499999 then	
				cnt1hz := 0;
				clk1hz <= not clk1hz;
			else
				cnt1hz := cnt1hz + 1;
			end if;
		end if;
		clk1hz_out <= clk1hz;
	end process;

-- 2Hz clock generation
	process(clk, clk2hz)
	variable		cnt2hz		: 	integer := 0;
	begin
		if rising_edge(clk) then
			if cnt2hz >= 249999 then	
--			if cnt2hz >= 5 then	
				cnt2hz := 0;
				clk2hz <= not clk2hz;
			else
				cnt2hz := cnt2hz + 1;
			end if;
		end if;
		clk2hz_out <= clk2hz;
	end process;

-- 100Hz clock generation
	process(clk)
		variable		cnt100hz	: integer := 0;
	begin
		if rising_edge(clk) then
			if cnt100hz >= 4999 then
				cnt100hz := 0;
				clk100Hz <= not clk100Hz;
			else
				cnt100hz := cnt100hz + 1;
			end if;
			clk100hz_out <= clk100hz;
		end if;
	end process;		

	process(sw0)
	begin
		if rising_edge(sw0) then
			mode <= mode + '1';
		end if;
	end process;
	mode_out <= mode;
	
	process(reset, sw1)
	begin
		if reset = '0' then
			set_pos <= "100";
		elsif rising_edge(sw1) then
			if (mode = "01") or (mode = "10") then
				case set_pos is
					when "100" => 
						set_pos <= "010";
					when "010" => 
						set_pos <= "001";
					when "001" => 
						set_pos <= "100";
					when others =>
						set_pos <= null;
				end case;
			end if;	
		end if;
	end process;

	process(mode, set_pos)
	begin
		case mode is 
			when "01"|"10" => 
				set_pos_out <= set_pos;
			when others =>	
				set_pos_out <= "000";
		end case;		
	end process;	
end Behavioral;