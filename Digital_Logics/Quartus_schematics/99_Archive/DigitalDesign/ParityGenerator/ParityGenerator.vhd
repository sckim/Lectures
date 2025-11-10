library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ParityGenerator is
	generic (n : integer := 8);
	port(	data_in		: in std_logic_vector(n-1 downto 0);
			parity_out	: out std_logic_vector(n downto 0));
end ParityGenerator;

architecture  Behavioral of ParityGenerator is

function parity(x:std_logic_vector)	return std_logic_vector is
	variable tmp1 : std_logic := '0';
	variable tmp2 : std_logic_vector(n downto 0);
begin
	for i in x'range loop
		tmp1 := tmp1 xor x(i);
		tmp2(i) := x(i);
	end loop;
	tmp2(n) := tmp1;
	return tmp2;
end parity;	

begin
	process(data_in)
	begin
		parity_out <= parity(data_in);
	end process;
end  Behavioral;