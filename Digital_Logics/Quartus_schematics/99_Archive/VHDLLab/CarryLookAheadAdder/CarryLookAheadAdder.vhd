library ieee;
use ieee.std_logic_1164.ALL;

package MyPackage is
	component CarryAheadGen 
		port(	g, p	: in	std_logic_vector(3 downto 0);
				c		: out	std_logic_vector(4 downto 1));
	end component;
   
	component Middle is
		port(	a, b	: in	std_logic;
				p, g	: out	std_logic);
	end component;
	
	component XOR2 is
		port(	p, c	: in	std_logic;
				s		: out	std_logic);
	end component;	
end MyPackage;

library ieee;
use ieee.std_logic_1164.ALL;
library work;
use work.MyPackage.all;

entity CarryLookAheadAdder is    
    PORT(	clk					: in std_logic;
				x, y					: in std_logic_vector(3 downto 0);
				FND					: out std_logic_vector(6 downto 0);
				FNDSel1, FNDSel2	: out std_logic);
end CarryLookAheadAdder;

architecture Behavioral of CarryLookAheadAdder is
	signal p, g			:	std_logic_vector(3 downto 0);
	signal sum			:	std_logic_vector(3 downto 0);
	signal c				:	std_logic_vector(4 downto 1);
	signal clk100Hz	: std_logic;
	signal FNDVal2, FNDVal1	: std_logic_vector(6 downto 0);
	
begin
	mid		:	for i in 0 to 3 generate
					mid1to4	:	Middle port map(x(i), y(i), p(i), g(i));
				end generate;

	carry	:	CarryAheadGen
					port map(g, p, c);

	out0	:	XOR2 port map(p(0), '0', sum(0));
	
	out1to3	:	for j in 1 to 3 generate
					xor1to3 :	XOR2 port map(p(j), c(j), sum(j));
				end generate;	

	process(clk)
		variable	m	: integer := 0;
	begin
		if rising_edge(clk) then
			if m >= 4999 then
				m := 0;
				clk100Hz <= not clk100Hz;
			else
				m := m + 1;
			end if;
		end if;
	end process;		

	process(sum, c(4))
	begin
		case sum is
--							   		"abcdefg"
			when "0000"	=> FNDVal1 <= "1111110"; 
			when "0001"	=> FNDVal1 <= "0110000"; 
			when "0010"	=> FNDVal1 <= "1101101"; 
			when "0011"	=> FNDVal1 <= "1111001"; 
			when "0100"	=> FNDVal1 <= "0110011"; 
			when "0101"	=> FNDVal1 <= "1011011"; 
			when "0110"	=> FNDVal1 <= "1011111"; 
			when "0111"	=> FNDVal1 <= "1110000"; 
			when "1000"	=> FNDVal1 <= "1111111"; 
			when "1001"	=> FNDVal1 <= "1110011"; 
			when "1010"	=> FNDVal1 <= "1111101"; 
			when "1011"	=> FNDVal1 <= "0011111"; 
			when "1100"	=> FNDVal1 <= "0001101"; 
			when "1101"	=> FNDVal1 <= "0111101"; 
			when "1110"	=> FNDVal1 <= "1101111"; 
			when "1111"	=> FNDVal1 <= "1000111";
			when others => FNDVal1 <= "0000000";
		end case;

		case c(4) is
--							"abcdefg"
			when '0'	=> FNDVal2 <= "1111110"; 
			when '1'	=> FNDVal2 <= "0110000"; 
			when others => FNDVal2 <= "0000000";
		end case;
	end process;

	process(clk100Hz, FNDVal2, FNDVal1)
	begin
		if (clk100Hz = '1') then
			FNDSel2 <= '0';
			FNDSel1 <= '1';
			FND <= FNDVal2;
		else	
			FNDSel2 <= '1';
			FNDSel1 <= '0';
			FND <= FNDVal1;
		end if;
	end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.ALL;

entity CarryAheadGen is 
	port(	g, p	: in	std_logic_vector(3 downto 0);
			c		: out	std_logic_vector(4 downto 1));
end CarryAheadGen;

architecture designCarry of CarryAheadGen is
begin
	c(1) <= g(0);
	c(2) <= g(1) or (p(1) and g(0));
	c(3) <= g(2) or (p(2) and g(1)) or (p(2) and p(1) and g(0));
	c(4) <= g(3) or (p(3) and g(2)) or (p(3) and p(2) and g(1)) 
			or (p(3) and p(2) and p(1) and g(0)); 
end designCarry;

library ieee;
use ieee.std_logic_1164.ALL;

entity XOR2 is 
		port(	p, c	: in	std_logic;
				s		: out	std_logic);
end XOR2;

architecture designXOR2 of XOR2 is
begin
	s <= p xor c;
end designXOR2;

library ieee;
use ieee.std_logic_1164.ALL;

entity Middle is
	port(	a, b	: in	std_logic;
			p, g	: out	std_logic);
end Middle;

architecture designMiddle of Middle is
begin
	p <= a xor b;
	g <= a and b;
end designMiddle;