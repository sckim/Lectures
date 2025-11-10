library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullSubtractor is
	port(	Xi, Yi, Bi	: in	integer range 0 to 1;
			Di, B			: out 	std_logic);

end FullSubtractor;

architecture Behavioral of FullSubtractor is
	signal diff		: integer range -2 to 1;
begin
	process(Xi, Yi, Bi, diff)
	begin
		diff <= Xi - Yi - Bi;
		if diff = -2 then
			Di <= '0';
			B <= '1';
		elsif diff = -1 then
			Di <= '1';
			B <= '1';
		elsif diff = 0 then
			Di <= '0';
			B <= '0';
		else
			Di <= '1';
			B <= '0';
		end if;
	end process;
end Behavioral;

