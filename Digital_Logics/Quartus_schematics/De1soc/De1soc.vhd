--library ieee;
--use ieee.std_logic_1164.all;
--
--
--entity DE1SoC is
--Port (
--	LEDRs: out STD_LOGIC_VECTOR(9 downto 0);
--   SWs  : in  STD_LOGIC_VECTOR(9 downto 0);
--	HEX0 : out STD_LOGIC_VECTOR(6 downto 0);
--   HEX1 : out STD_LOGIC_VECTOR(6 downto 0);
--   KEYs : in STD_LOGIC_VECTOR(3 downto 0)
--   );
--
--end DE1Soc;
--
--architecture Behavioral of DE1Soc is
--begin
--    LEDRs <= SWs;
--    HEX0(3 downto 0) <= KEYs;
--
--    with KEYs select HEX1 <=
--        "1000000" when "0000", -- 0
--        "1111001" when "0001", -- 1
--        "0100100" when "0010", -- 2
--        "0110000" when "0011", -- 3
--        "0011001" when "0100", -- 4
--        "0010010" when "0101", -- 5
--        "0000010" when "0110", -- 6
--        "1111000" when "0111", -- 7
--        "0000000" when "1000", -- 8
--        "0010000" when "1001", -- 9
--        "0001000" when "1010", -- A
--        "0000011" when "1011", -- B
--        "1000110" when "1100", -- C
--        "0100001" when "1101", -- D
--        "0000110" when "1110", -- E
--        "0001110" when "1111", -- F
--        "1111111" when others; -- 그   
--end Behavioral;

library ieee;
use ieee.std_logic_1164.all;

entity DE1SoC is
	Port (
		LEDRs: out STD_LOGIC_VECTOR(9 downto 0);
      SWs  : in  STD_LOGIC_VECTOR(9 downto 0);
      KEYs : in STD_LOGIC_VECTOR(3 downto 0);
		
		HEX0 : out STD_LOGIC_VECTOR(6 downto 0);
      HEX1 : out STD_LOGIC_VECTOR(6 downto 0);
		HEX2 : out STD_LOGIC_VECTOR(6 downto 0);
		HEX3 : out STD_LOGIC_VECTOR(6 downto 0);

		HEX5 : out STD_LOGIC_VECTOR(6 downto 0)
    );
end DE1Soc;

architecture Behavioral of DE1Soc is
begin
    LEDRs <= SWs;
 
	 with KEYs(0) select HEX0 <=
		"1111001" when '0',
		"1000000" when '1';

	 with KEYs(1) select HEX1 <=
		"1111001" when '0',
		"1000000" when '1';

	 with KEYs(2) select HEX2 <=
		"1111001" when '0',
		"1000000" when '1';
	
	 with KEYs(3) select HEX3 <=
		"1111001" when '0',
		"1000000" when '1';
		
    with not KEYs select HEX5 <=
        "1000000" when "0000", -- 0
        "1111001" when "0001", -- 1
        "0100100" when "0010", -- 2
        "0110000" when "0011", -- 3
        "0011001" when "0100", -- 4
        "0010010" when "0101", -- 5
        "0000010" when "0110", -- 6
        "1111000" when "0111", -- 7
        "0000000" when "1000", -- 8
        "0010000" when "1001", -- 9
        "0001000" when "1010", -- A
        "0000011" when "1011", -- B
        "1000110" when "1100", -- C
        "0100001" when "1101", -- D
        "0000110" when "1110", -- E
        "0001110" when "1111", -- F
        "1111111" when others; -- 그 		  
	 
end Behavioral;
