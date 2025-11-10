LIBRARY ieee;						------------------------------
USE ieee.std_logic_1164.ALL;		-- BCD to 7 Segment Decoder --
									------------------------------
ENTITY bcdto7seg IS					
	PORT(SW		: IN 	std_logic_vector(3 downto 0);
		 HEX0	: OUT	std_logic_vector(0 to 6);
		 LEDR	: OUT	std_logic_vector(3 downto 0) );
END bcdto7seg;	

ARCHITECTURE arc OF bcdto7seg IS	
	SIGNAL bcd_in 	: std_logic_vector (3 downto 0);
	SIGNAL out_segs	: std_logic_vector (0 to 6);
BEGIN
	bcd_in <= SW;
	LEDR <= SW;
	
	WITH bcd_in SELECT
		out_segs <=	"0000001" WHEN "0000",
					"1001111" WHEN "0001",
					"0010010" WHEN "0010",
					"0000110" WHEN "0011",
					"1001100" WHEN "0100",
					"0100100" WHEN "0101",
					"1100000" WHEN "0110",
					"0001111" WHEN "0111",
					"0000000" WHEN "1000",
					"0001100" WHEN "1001",
					"0001000" WHEN "1010",
					"1100000" WHEN "1011",
					"1110010" WHEN "1100",
					"1000010" WHEN "1101",
					"0110000" WHEN "1110",
					"0111000" WHEN "1111",
					"0000000" WHEN others;
		HEX0 <= out_segs;
END arc;

--LIBRARY ieee;						------------------------------
--USE ieee.std_logic_1164.ALL;		-- BCD to 7 Segment Decoder --
--									------------------------------
--ENTITY bcdto7seg IS					
--	PORT(A3, A2, A1, A0				: IN 	std_logic;
--		na, nb, nc, nd, ne, nf, ng	: OUT	std_logic);
--END bcdto7seg;	
--
--ARCHITECTURE arc OF bcdto7seg IS	
--	SIGNAL bcd_in 	: std_logic_vector (3 DOWNTO 0);
--	SIGNAL out_segs	: std_logic_vector (6 DOWNTO 0);
--BEGIN
--	bcd_in <= A3 & A2 & A1 & A0;
--	WITH bcd_in SELECT
--		out_segs <=	"0000001" WHEN "0000",
--					"1001111" WHEN "0001",
--					"0010010" WHEN "0010",
--					"0000110" WHEN "0011",
--					"1001100" WHEN "0100",
--					"0100100" WHEN "0101",
--					"1100000" WHEN "0110",
--					"0001111" WHEN "0111",
--					"0000000" WHEN "1000",
--					"0001100" WHEN "1001",
--					"1111111" WHEN others;
--		na	<=	out_segs(6);
--		nb	<=	out_segs(5);
--		nc	<=	out_segs(4);
--		nd	<=	out_segs(3);
--		ne	<=	out_segs(2);
--		nf	<=	out_segs(1);
--		ng	<=	out_segs(0);
--END arc;
