library ieee;
use ieee.std_logic_1164.ALL;
package UserAdder is
	component FullAdder 
		port(	a, b, c_in	:	in std_logic;
				sum, c_out  :	out std_logic);
	end component;
   
	component HalfAdder
		port(	a, b		: in std_logic;
				sum, c_out	: out std_logic);
	end component;		
end UserAdder;

library ieee;
use ieee.std_logic_1164.ALL;
entity FullAdder is 
	port(	a, b, c_in		: in    std_logic;
			sum, c_out		: out   std_logic);
end FullAdder;

architecture designFA of FullAdder is
begin
    sum <= (not a and not b and c_in) or (not a and b and not c_in)
		or (a and not b and not c_in) or (a and b and c_in);
    c_out <= (a and b) or (a and c_in) or (b and c_in);
end designFA;

library ieee;
use ieee.std_logic_1164.ALL;

entity HalfAdder is 
    port(	a, b		: in    std_logic;
			sum, c_out	: out   std_logic);
end HalfAdder;

architecture designHA of HalfAdder is
begin
    sum <= (not a and b) or (a and not b);
    c_out <= a and b;
end designHA;

library ieee;
use ieee.std_logic_1164.ALL;

library work;
use work.UserAdder.all;

entity RippleAdder is    
    port(clk					: std_logic;
			x, y					: in std_logic_vector(3 downto 0);
			FND					: out std_logic_vector(6 downto 0);
			FNDSel2, FNDSel1	: out std_logic);
end RippleAdder;

architecture  Behavioral of RippleAdder is
		signal c  				: std_logic_vector(2 downto 0);
		signal sum				: std_logic_vector(3 downto 0);
		signal c_out			: std_logic;
		signal clk100Hz		: std_logic;
		signal FNDVal2, FNDVal1	: std_logic_vector(6 downto 0);
begin
	c0	: HalfAdder 
		port map (x(0), y(0), sum(0), c(0));
   c12	: for i in 1 to 2 generate
		c1to2:  FullAdder port map(x(i), y(i), c(i-1), sum(i), c(i));
		end generate;
	c3	: FullAdder port map(x(3), y(3), c(2), sum(3), c_out);
	
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
	
	process(sum, c_out)
	begin
		case sum is
--							   		      "abcdefg"
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

		case c_out is
--							   		   "abcdefg"
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
end  Behavioral;

