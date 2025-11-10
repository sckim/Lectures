LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Counter IS 
	PORT (	Clk, Reset				: IN	STD_LOGIC;
			HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);
			HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6)
			);
END Counter;

ARCHITECTURE Structure OF Counter IS
	COMPONENT counter10
			PORT(n_cp, n_rd			: IN	STD_LOGIC;
				 cnt			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;

	COMPONENT counter10_1
			PORT(n_cp, n_rd			: IN	STD_LOGIC;
				 cnt				: BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0) );
	END COMPONENT;
	
	COMPONENT counter100
			PORT(n_cp, n_rd			: IN	STD_LOGIC;
				 cnt				: OUT   STD_LOGIC);
	END COMPONENT;
	
	COMPONENT counter5
			PORT(n_cp, n_rd			: IN	STD_LOGIC;
				 cnt				: OUT   STD_LOGIC);
	END COMPONENT;
	
	COMPONENT bcd_decoder
		PORT(In_data 	: IN std_logic_vector(3 DOWNTO 0);
			 Segment  	: OUT std_logic_vector(0 TO 6));
	END COMPONENT;
	
	--SIGNAL Cnt10000_0 : STD_LOGIC;	
	SIGNAL Cnt0, Cnt1, Cnt2, Cnt3, Cnt4, Cnt5, Cnt6, Cnt7 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Cnt100_0, Cnt100_1, Cnt100_2 : STD_LOGIC;
BEGIN
	
	-- instantiate counte;
	C7: counter10 PORT MAP (n_cp=>Cnt6(3), n_rd=>Reset, cnt=>Cnt7);
	C6: counter10 PORT MAP (n_cp=>Cnt5(3), n_rd=>Reset, cnt=>Cnt6);
	C5: counter10 PORT MAP (n_cp=>Cnt4(3), n_rd=>Reset, cnt=>Cnt5);
	C4: counter10 PORT MAP (n_cp=>Cnt3(3), n_rd=>Reset, cnt=>Cnt4);
	C3: counter10 PORT MAP (n_cp=>Cnt2(3), n_rd=>Reset, cnt=>Cnt3);
	C2: counter10 PORT MAP (n_cp=>Cnt1(3), n_rd=>Reset, cnt=>Cnt2);
	C1: counter10 PORT MAP (n_cp=>Cnt0(3), n_rd=>Reset, cnt=>Cnt1);
	C0: counter10 PORT MAP (n_cp=>Clk, n_rd=>Reset, cnt=>Cnt0);
	
	C8: counter100 PORT MAP (n_cp=>Clk, n_rd=>Reset, cnt=>Cnt100_0);
	C9: counter100 PORT MAP (n_cp=>Cnt100_0, n_rd=>Reset, cnt=>Cnt100_1);
	C10: counter100 PORT MAP (n_cp=>Cnt100_1, n_rd=>Reset, cnt=>Cnt100_2);
	
	-- instantiate bcd_decoder (C, Display);
	H7: bcd_decoder PORT MAP (Cnt7, HEX7);
	H6: bcd_decoder PORT MAP (Cnt6, HEX6);
	H5: bcd_decoder PORT MAP (Cnt5, HEX5);
	H4: bcd_decoder PORT MAP (Cnt4, HEX4);
	H3: bcd_decoder PORT MAP (Cnt3, HEX3);
	H2: bcd_decoder PORT MAP (Cnt2, HEX2);
	H1: bcd_decoder PORT MAP (Cnt1, HEX1);
	H0: bcd_decoder PORT MAP (Cnt0, HEX0);
	
END Structure;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY bcd_decoder IS
	PORT(In_data	: IN std_logic_vector(3 DOWNTO 0);
		 Segment	: OUT std_logic_vector(0 TO 6));
END bcd_decoder;

ARCHITECTURE arc OF bcd_decoder IS
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
				"0110001" WHEN "1100",	-- C
				"1000010" WHEN "1101",	-- D
				"0110000" WHEN "1110",	-- E
				"0111000" WHEN "1111",	-- F				
				"1111111" WHEN OTHERS;
END arc;

LIBRARY ieee;				     -----------------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-10 Glitch-Free Up-Counter --
							     -----------------------------------
ENTITY counter10 IS		     
	PORT(n_cp, n_rd		: IN	std_logic;
		 cnt			: OUT   integer RANGE 0 TO 15);
END counter10;

ARCHITECTURE arc OF counter10 IS
	Signal Q: integer RANGE 0 TO 15;
BEGIN
	PROCESS (n_cp, n_rd)
	BEGIN
		IF  (n_rd='0') THEN
			Q <= 0;
		ELSIF (n_cp'EVENT AND n_cp='0' )  THEN
			IF (Q >= 9) THEN
		      	Q <= 0;
		    ELSE
				Q <= Q+1;
			END IF;
		END IF;
	END PROCESS;
	cnt <= Q;
END arc;

LIBRARY ieee;				     -----------------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-10 Glitch-Free Up-Counter --
							     -----------------------------------
ENTITY counter10_1 IS		     
	PORT(n_cp, n_rd		: IN	std_logic;
		 Cnt			: BUFFER std_logic_vector(3 downto 0));
END counter10_1;

ARCHITECTURE arc OF counter10_1 IS
BEGIN
	PROCESS (n_cp, n_rd)
	BEGIN
		IF  (n_rd='0') THEN
			Cnt <= "0000";
		ELSIF (n_cp'EVENT AND n_cp='0' ) THEN
			Cnt(0) <= not Cnt(0);
			IF Cnt = "1001" THEN
				Cnt <= "0000";
			ELSIF Cnt(0) = '1' THEN
				Cnt(1) <= not Cnt(1);
				IF Cnt(1) = '1' THEN
					Cnt(2) <= not Cnt(2);
					IF Cnt(2) = '1' THEN
						Cnt(3) <= not Cnt(3);
					END IF;
				END IF;
			END IF;
		END IF;		
	END PROCESS;
END arc;

LIBRARY ieee;				     -----------------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-10 Glitch-Free Up-Counter --
							     -----------------------------------
ENTITY counter100 IS		     
	PORT(n_cp, n_rd		: IN	std_logic;
		 cnt			: OUT	std_logic );
END counter100;

ARCHITECTURE arc OF counter100 IS
	Signal Q: integer range 0 to 99;
BEGIN
	PROCESS (n_cp, n_rd)
	BEGIN
		IF  (n_rd='0') THEN
			Q <= 0;
			ELSIF (n_cp'EVENT AND n_cp='0' ) THEN
				IF (Q=99) THEN
					Q <= 0;
					cnt <= '1';
			    ELSE
					Q <= Q + 1;
					cnt <= '0';
				END IF;
		END IF;
	END PROCESS;
END arc;