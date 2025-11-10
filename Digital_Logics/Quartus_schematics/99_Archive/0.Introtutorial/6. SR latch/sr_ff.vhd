library IEEE;
use IEEE.std_logic_1164.all;

--     NOR_RSFF
entity NOR_RSFF is
	port ( R, S   : in  std_logic;
	       Q, Q_B : out std_logic );
end NOR_RSFF;

architecture NOR_RSFF of NOR_RSFF is
	signal FF_Q, FF_Q_B : std_logic;
begin
	Q <= FF_Q; Q_B <= FF_Q_B;
end NOR_RSFF;