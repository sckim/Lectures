library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TrafficLightController is
	port(	clk, standby, test	: in std_logic;
			G1Y1, R1G2, Y2R2		: out	std_logic_vector(6 downto 0);
			G1en, Y1en, R1en		: out std_logic;
			G2en, Y2en, R2en		: out	std_logic);
end TrafficLightController;

architecture Behavioral of TrafficLightController is
	constant RGTime				: integer	:= 10;
	constant RYTime 				: integer	:= 3;
	constant GRTime 				: integer	:= 15;
	constant YRTime				: integer	:= 3;
	constant TESTTime				: integer	:= 2;	
	type state_type is (RG, RY, GR, YR, YY);
	signal state					: state_type;
	signal TimeCnt					: integer range 0 to 15;	
	signal clk1hz, clk100hz		: std_logic;
	signal onTime					: integer range 0 to 15;
	signal G1, Y1, R1, G2, Y2, R2	: std_logic_vector(6 downto 0);
begin
	process(clk, clk1hz, clk100hz)
		variable		cnt1hz		: integer := 0;
		variable		cnt100hz		: integer := 0;
	begin
		if rising_edge(clk) then
			if cnt1hz >= 499999 then	
				cnt1hz := 0;
				clk1hz <= not clk1hz;
			else
				cnt1hz := cnt1hz + 1;
			end if;
		end if;
		
		if rising_edge(clk) then
			if cnt100hz >= 4999 then	
				cnt100hz := 0;
				clk100hz <= not clk100hz;
			else
				cnt100hz := cnt100hz + 1;
			end if;
		end if;
	end process;
	
-- process for deciding next state and conditional output
	process(standby, clk1hz, TimeCnt, state, test)
	begin
		if rising_edge(clk1hz) then
			if standby = '1' then
				state <= YY;
				TimeCnt <= 0;
			else
				case state is
					when RG =>
						if (test = '0') then onTime <= RGTime;
						else onTime <= TESTTime;
						end if;

						TimeCnt <= TimeCnt + 1;
						if TimeCnt = onTime then
							state <= RY;
							TimeCnt <= 0;
						end if;	
					when RY =>
						if (test='0') then onTime <= RYTime;
						else onTime <= TESTTime;
						end if;

						TimeCnt <= TimeCnt + 1;
						if TimeCnt = onTime then
							state <= GR;
							TimeCnt <= 0;
						end if;	
					when GR =>
						if (test='0') then onTime <= GRTime;	
						else onTime <= TESTTime;
						end if;

						TimeCnt <= TimeCnt + 1;
						if TimeCnt = onTime then
							state <= YR;
							TimeCnt <= 0;
						end if;	
					when YR =>
						if (test='0') then onTime <= YRTime;
						else onTime <= TESTTime;
						end if;
						TimeCnt <= TimeCnt + 1;
						if TimeCnt = onTime then
							state <= RG;
							TimeCnt <= 0;
						end if;	
					when YY =>
						state <= RY;
				end case;
			end if;	
		end if;	
	end process;
	
	process(state)
	begin
		case state is
			when RG =>
				R1 <= "1111110"; Y1 <= "0000000"; G1 <= "0000000";
				R2 <= "0000000"; Y2 <= "0000000"; G2 <= "1111110"; 
			when RY =>
				R1 <= "1111110"; Y1 <= "0000000"; G1 <= "0000000";
				R2 <= "0000000"; Y2 <= "1111110"; G2 <= "0000000"; 
			when GR =>
				R1 <= "0000000"; Y1 <= "0000000"; G1 <= "1111110";
				R2 <= "1111110"; Y2 <= "0000000"; G2 <= "0000000"; 
			when YR =>
				R1 <= "0000000"; Y1 <= "1111110"; G1 <= "0000000";
				R2 <= "1111110"; Y2 <= "0000000"; G2 <= "0000000"; 
			when YY =>
				R1 <= "0000000"; Y1 <= "1111110"; G1 <= "0000000";
				R2 <= "0000000"; Y2 <= "1111110"; G2 <= "0000000"; 
		end case;
	end process;

	process(clk100Hz, G1, Y1, R1, G2, Y2, R2)
	begin
		if (clk100Hz = '1') then
			G1en <= '0';
			Y1en <= '1';
			R1en <= '0';
			G2en <= '1';
			Y2en <= '0';
			R2en <= '1';
			G1Y1 <= G1;
			R1G2 <= R1;
			Y2R2 <= Y2;
		else	
			G1en <= '1';
			Y1en <= '0';
			R1en <= '1';
			G2en <= '0';
			Y2en <= '1';
			R2en <= '0';
			G1Y1 <= Y1;
			R1G2 <= G2;
			Y2R2 <= R2;
		end if;
	end process;
end Behavioral;