library IEEE;
use IEEE.std_logic_1164.all;

entity ParityChecker is
	port(	data_in : in std_logic_vector(8 downto 0);
			parityCheck: out std_logic);
end ParityChecker;
	
architecture Behavioral of ParityChecker is
procedure parityProc(
	inp : in std_logic_vector(8 downto 0);
	outp : out std_logic) is
	variable tmp : std_logic;
	begin
		tmp := '0';
		for i in inp'range loop
			tmp := tmp xor inp(i);
		end loop;
		outp := tmp;
end parityProc;

begin
	process(data_in)
		variable	parity :	std_logic;
	begin	
		parityProc(data_in(8 downto 0), parity);
		parityCheck <= parity;
	end process;	
end Behavioral;