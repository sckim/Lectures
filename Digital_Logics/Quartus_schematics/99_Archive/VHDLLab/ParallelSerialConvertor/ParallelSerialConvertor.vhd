library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ParallelSerialConvertor is
	port(	clk, load	: in std_logic;
			p_in		: in std_logic_vector(7 downto 0);
			s_out		: out std_logic_vector(7 downto 0));
end ParallelSerialConvertor;

architecture Behavioral of ParallelSerialConvertor is
	signal 	reg, s_reg	: std_logic_vector(7 downto 0) := "00000000";
begin
	process(clk, load, p_in)
	begin
		if rising_edge(clk) then
			if load = '1' then
				reg <= p_in;
			else
				s_reg <= s_reg(6 downto 0) & reg(7);
				reg <= reg(6 downto 0) & '0';
			end if;
		end if;	
	end process;
	s_out <= s_reg;
end Behavioral;

