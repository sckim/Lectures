LIBRARY ieee;				 ------------------------------
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all;
							 -- 4-bit Binary Adder using --
							 --  Integer Arithmetic      --
ENTITY bits_adder IS			 ------------------------------
	PORT
	(
		A_bits	: IN	std_logic_vector(3 downto 0);
		B_bits	: IN	std_logic_vector(3 downto 0);
		S_bits	: buffer  	std_logic_vector(4 downto 0);
		
		A_HEX : OUT std_logic_vector(0 TO 6);
		B_HEX : OUT std_logic_vector(0 TO 6);
		S_HEX0 : OUT std_logic_vector(0 TO 6);
		S_HEX1 : OUT std_logic_vector(0 TO 6)
	);
END bits_adder ;

ARCHITECTURE arc OF bits_adder IS
	COMPONENT Bcd2Seg
		PORT(SW 	: IN std_logic_vector(3 DOWNTO 0);
		 HEX0	: OUT std_logic_vector(0 TO 6));
	END COMPONENT;

	signal cin: integer RANGE 0 TO 1;
	signal astring: integer RANGE 0 TO 15;
	signal bstring: integer RANGE 0 TO 15;
	signal sumstring: integer RANGE 0 TO 31;
	signal flag: integer RANGE 0 TO 1;
	
BEGIN	
	cin <= 0;
	astring <= to_integer( unsigned(A_bits) );
	bstring <= to_integer( unsigned(B_bits) );
	sumstring <= astring+bstring+cin;	
	
	S_bits <= std_logic_vector(to_unsigned(sumstring,5));

	A_seg: Bcd2Seg port map(A_bits, A_HEX);
	B_seg: Bcd2Seg port map(B_bits, B_HEX);
	S_seg0: Bcd2Seg port map(S_bits(3 downto 0), S_HEX0);	
	S_seg1: Bcd2Seg port map("000"&S_bits(4), S_HEX1);	
END arc;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Bcd2Seg IS
	PORT(SW 	: IN std_logic_vector(3 DOWNTO 0);
		 HEX0	: OUT std_logic_vector(0 TO 6));
END Bcd2Seg;

ARCHITECTURE arc OF Bcd2Seg IS
BEGIN 
	WITH SW SELECT
		HEX0 <= "0000001" WHEN "0000",	-- 0
				"1001111" WHEN "0001",	-- 1
				"0010010" WHEN "0010",	-- 2
				"0000110" WHEN "0011",	-- 3
				"1001100" WHEN "0100",	-- 4
				"0100100" WHEN "0101",	-- 5
				"0100000" WHEN "0110",	-- 6
				"0001111" WHEN "0111",	-- 7
				"0000000" WHEN "1000",	-- 8
				"0001100" WHEN "1001",	-- 9
				"1111111" WHEN OTHERS;
END arc;