library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity BCDCounter is
	port(	clk		: in	std_logic;
			reset	: in	std_logic;
			cnt_out	: out	std_logic_vector(3 downto 0);
			FND		: out	std_logic_vector(6 downto 0);
			FNDSel2, FNDSel1	: out std_logic);
end BCDCounter;

architecture Behavioral of BCDCounter is
	type STATE_TYPE is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9);
	signal state	: STATE_TYPE := S0;
	signal clk1Hz	: std_logic;	
	signal segReg	: std_logic_vector(3 downto 0);

begin
	process(clk)
		variable	m	: integer := 0;
	begin
		if rising_edge(clk) then
			if m >= 499999 then
				m := 0;
				clk1Hz <= not clk1Hz;
			else
				m := m + 1;
			end if;
		end if;
	end process;		

	process (reset, clk1Hz)
	begin
		if reset = '0' then
			state <= s0;
		elsif rising_edge(clk1Hz) then
			case state is
				when s0=> state <= s1;
				when s1=> state <= s2;
				when s2=> state <= s3;
				when s3=> state <= s4;
				when s4=> state <= s5;
				when s5=> state <= s6;
				when s6=> state <= s7;
				when s7=> state <= s8;
				when s8=> state <= s9;
				when s9=> state <= s0;
			end case;
		end if;
	end process;

	segReg <=	"0000" when state = s0 else
				"0001" when state = s1 else
				"0010" when state = s2 else
				"0011" when state = s3 else
				"0100" when state = s4 else
				"0101" when state = s5 else
				"0110" when state = s6 else
				"0111" when state = s7 else
				"1000" when state = s8 else
				"1001";

-- process for 7-segment display
	FNDSel2 <= '1';
	FNDSel1 <= '0';
	process(segReg)
	begin
		case segReg is
--								  	"abcdefg-"
			when "0000"	=> FND <= 	"1111110"; 
			when "0001"	=> FND <= 	"0110000"; 
			when "0010"	=> FND <= 	"1101101"; 
			when "0011"	=> FND <= 	"1111001"; 
			when "0100"	=> FND <= 	"0110011"; 
			when "0101"	=> FND <= 	"1011011"; 
			when "0110"	=> FND <= 	"1011111"; 
			when "0111"	=> FND <= 	"1110000"; 
			when "1000"	=> FND <= 	"1111111"; 
			when "1001"	=> FND <= 	"1110011"; 
			when others => FND <= 	"0000000";
		end case;
	end process;
	cnt_out <= segReg;
end Behavioral;