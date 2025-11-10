LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Counter IS 
	PORT (	Clock_50, Reset				: IN	STD_LOGIC;
			HEX7, HEX6, HEX5, HEX4	: OUT	STD_LOGIC_VECTOR(0 TO 6);
			HEX3, HEX2, HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6)
			);
END Counter;

ARCHITECTURE Structure OF Counter IS
	COMPONENT counter10
			PORT(n_cp, n_rd			: IN	STD_LOGIC;
				 q					: BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0) );
	END COMPONENT;

	COMPONENT Mod50MHz
			PORT(n_cp, n_rd		: IN	STD_LOGIC;
				 q				: BUFFER STD_LOGIC_VECTOR(25 DOWNTO 0) );
	END COMPONENT;
	
	COMPONENT bcd_decoder
		PORT(In_data 	: IN std_logic_vector(3 DOWNTO 0);
			 Segment  	: OUT std_logic_vector(0 TO 6));
	END COMPONENT;
	
	--SIGNAL Cnt0, Cnt1, Cnt2, Cnt3, Cnt4, Cnt5, Cnt6, Cnt7 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Cnt50M : STD_LOGIC_VECTOR(25 DOWNTO 0);	
	SIGNAL Cnt0, Cnt1, Cnt2, Cnt3, Cnt4, Cnt5, Cnt6, Cnt7 : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
	
	-- instantiate counte;
	C7: counter10 PORT MAP (Cnt6(3), Reset, Cnt7);
	C6: counter10 PORT MAP (Cnt5(3), Reset, Cnt6);
	C5: counter10 PORT MAP (Cnt4(3), Reset, Cnt5);
	C4: counter10 PORT MAP (Cnt3(3), Reset, Cnt4);
	C3: counter10 PORT MAP (Cnt2(3), Reset, Cnt3);
	C2: counter10 PORT MAP (Cnt1(3), Reset, Cnt2);
	C1: counter10 PORT MAP (Cnt0(3), Reset, Cnt1);
	C0: counter10 PORT MAP (Clock_50, Reset, Cnt0);
	
	--C1: counter10 PORT MAP (Cnt0(3), Reset, Cnt1);	
	--C0: counter10 PORT MAP (Cnt50M(25), Reset, Cnt0);	
	--C11: Mod50MHz PORT MAP (Clock_50, Reset, Cnt50M);	
	
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
	PORT(n_cp, n_rd			: IN	std_logic;
		 q					: BUFFER integer RANGE 0 TO 9);
END counter10;

ARCHITECTURE arc OF counter10 IS
BEGIN
	PROCESS (n_cp, n_rd)
	BEGIN
		IF  (n_rd='0') THEN
			q<= 0;
			ELSIF (n_cp'EVENT AND n_cp='0' ) THEN
				IF (q=9) THEN
			      	q<=0;
			      	ELSE q<=q+1;
				END IF;
		END IF;
	END PROCESS;
END arc;


LIBRARY ieee;				     -----------------------------------
USE ieee.std_logic_1164.ALL;     -- Mod-100000 Glitch-Free Up-Counter --
							     -----------------------------------
ENTITY Mod50MHz IS		     
	PORT(n_cp, n_rd		: IN	STD_LOGIC;
		 q				: BUFFER INTEGER RANGE 0 to 50000000 );
END Mod50MHz;

ARCHITECTURE arc OF Mod50MHz IS
BEGIN
	PROCESS (n_cp, n_rd)
	BEGIN
		IF  (n_rd='0') THEN
			q <= 0;
			ELSIF (n_cp'EVENT AND n_cp='0' ) THEN
				IF (q=49999999) THEN
			      	q <=0;
			      	ELSE q <= q+1;
				END IF;
		END IF;
	END PROCESS;
END arc;