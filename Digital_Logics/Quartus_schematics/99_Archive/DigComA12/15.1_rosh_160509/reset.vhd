library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY reset IS
	PORT(	clk		: IN	std_logic;
			reset_in	: in 	std_logic;
			reset_out : out	std_logic);
END reset;

ARCHITECTURE design of reset IS
	signal	reset_node	: std_logic := '0';

BEGIN

	PROCESS (clk)
		variable	cnt : integer range 0 to 1000000;
	BEGIN
		if rising_edge(clk) then
			if cnt < 1000000 then
			--if cnt < 10 then
				cnt := cnt + 1;
				reset_node <= '0';
			elsif cnt >= 1000000 then
			--elsif cnt >= 10 then
				cnt := cnt + 0;
				reset_node <= '1';
			end if;
		end if;
	END PROCESS;
	reset_out <= reset_node and reset_in;
END design;
