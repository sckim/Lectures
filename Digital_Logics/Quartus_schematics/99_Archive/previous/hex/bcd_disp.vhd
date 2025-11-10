LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hex_disp IS 
	PORT (	SW 						: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
			LEDR					: OUT	STD_LOGIC_VECTOR(15 DOWNTO 0);
			HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);
			HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END hex_disp;

ARCHITECTURE Structure OF hex_disp IS
	COMPONENT SegmentDecoder
		PORT(In_data 	: IN std_logic_vector(3 DOWNTO 0);
			 Segment  	: OUT std_logic_vector(0 TO 6));
	END COMPONENT;
	
	SIGNAL H3_Ch, H2_Ch, H1_Ch, H0_Ch : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Blank : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
	LEDR <= SW;

	H3_Ch <= SW(15 DOWNTO 12);
	H2_Ch <= SW(11 DOWNTO 8);
	H1_Ch <= SW(7 DOWNTO 4);
	H0_Ch <= SW(3 DOWNTO 0);
	Blank <= "UUUU";	-- used to blank a 7-seg display (see module bcd_decoder)

	-- instantiate bcd_decoder (C, Display);
	H7: SegmentDecoder PORT MAP (In_data=>Blank, Segment=>HEX7);
	H6: SegmentDecoder PORT MAP (In_data=>Blank, Segment=>HEX6);
	H5: SegmentDecoder PORT MAP (In_data=>Blank, Segment=>HEX5);
	H4: SegmentDecoder PORT MAP ("UUUU", Segment=>HEX4);
	H3: SegmentDecoder PORT MAP (In_data=>H3_Ch, Segment=>HEX3);
	H2: SegmentDecoder PORT MAP (In_data=>H2_Ch, Segment=>HEX2);
	H1: SegmentDecoder PORT MAP (In_data=>H1_Ch, Segment=>HEX1);
	H0: SegmentDecoder PORT MAP (In_data=>H0_Ch, Segment=>HEX0);
END Structure;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY SegmentDecoder IS
	PORT(In_data	: IN std_logic_vector(3 DOWNTO 0);
		 Segment	: OUT std_logic_vector(0 TO 6));
END SegmentDecoder;

ARCHITECTURE arc OF SegmentDecoder IS
BEGIN 
	WITH In_data SELECT
		Segment <= "0000001" WHEN "0000",	-- 0
				"1001111" WHEN "0001",	-- 1
				"0010010" WHEN "0010",	-- 2
				"0000110" WHEN "0011",	-- 3
				"1001100" WHEN "0100",	-- 4
				"0100100" WHEN "0101",	-- 5
				"0100000" WHEN "0110",	-- 6
				"0001111" WHEN "0111",	-- 7
				"0000000" WHEN "1000",	-- 8
				"0001100" WHEN "1001",	-- 9
				"0001000" WHEN "1010",	-- A
				"1100000" WHEN "1011",	-- B
				"1110010" WHEN "1100",	-- C
				"1000010" WHEN "1101",	-- D
				"0110000" WHEN "1110",	-- E
				"0111000" WHEN "1111",	-- F				
				"1111111" WHEN OTHERS;
END arc;

						   