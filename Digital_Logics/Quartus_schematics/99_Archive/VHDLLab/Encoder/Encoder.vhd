library ieee;
use ieee.std_logic_1164.all;

entity Encoder is
	port(	D : in std_logic_vector(7 downto 0);
			en : in std_logic;
			A : out std_logic_vector(2 downto 0);
			v : out std_logic);
end Encoder;

architecture design of Encoder is
begin 
	process(en, D)
	begin
		A <= "000";
		v <= '0';
		if en='1' then
			if D(7) = '1' then 
				V <= '1';
				A <= "111";
			elsif D(6) = '1' then 	
				V <= '1';
				A <= "110";
			elsif D(5) = '1' then	
				V <= '1';
				A <= "101";
			elsif D(4) = '1' then
				V <= '1';
				A <= "100";
			elsif D(3) = '1' then
				V <= '1';
				A <= "011";
			elsif D(2) = '1' then	
				V <= '1';
				A <= "010";
			elsif D(1) = '1' then
				V <= '1';
				A <= "001";
			elsif D(0) = '1' then
				V <= '1';
				A <= "000";
			else
				V <= '0';
				A <= "000";
			end if;
		end if;	
	end process;			
end design;