LIBRARY ieee;					-------------------------------------
USE ieee.std_logic_1164.ALL;    -- Entering a Truth Table Using
								--  a Vector, a Signal and
ENTITY fig5_62 IS				--  Selected Signal Assignment
   	PORT(						-------------------------------------
        a,b,c		: IN std_logic;
        x			: OUT std_logic);
END fig5_62;

ARCHITECTURE arc OF fig5_62 IS	
		SIGNAL input : std_logic_vector(2 DOWNTO 0);
	BEGIN
	  input(2)<=a; --move a to element 2 of the internal vector signal
	  input(1)<=b; --move b to element 1 of the internal vector signal
	  input(0)<=c; --move c to element 0 of the internal vector signal
	  WITH input SELECT
			x <= '1' WHEN "000", -- x equals 1 when input equals "000"
				 '0' WHEN "001", -- x equals 0 when input equals "001"
			     '1' WHEN "010", -- x equals 1 when input equals "010"
		    	 '0' WHEN "011", -- x equals 0 when input equals "011"
			     '1' WHEN "100", -- x equals 1 when input equals "100"
			     '1' WHEN "101", -- x equals 1 when input equals "101"
			     '1' WHEN "110", -- x equals 1 when input equals "110"
			     '0' WHEN "111", -- x equals 0 when input equals "111"
			     '1' WHEN others;
END arc;
