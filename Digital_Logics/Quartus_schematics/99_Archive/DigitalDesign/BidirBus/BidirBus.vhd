library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BidirBus is
	port(	clk		: in std_logic;
			oe			: in std_logic;
			inp		: in	std_logic_vector(7 downto 0);
			outp		: out	std_logic_vector(7 downto 0);
			iop		: inout std_logic_vector(7 downto 0));
end BidirBus;

architecture Behavioral of BidirBus is
	signal outbuf : std_logic_vector(7 downto 0);
begin
	outbuf <= inp;
	process(clk, inp, oe, outbuf, iop)
	begin
		if rising_edge(clk) then
			if oe = '1' then	-- output
				iop <= outbuf;
				outp <= "ZZZZZZZZ";
			else				-- input
				iop <= "ZZZZZZZZ";
				outp <= iop;
			end if;
		end if;	
	end process;
end Behavioral;