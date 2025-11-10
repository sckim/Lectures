library ieee;
use ieee.std_logic_1164.all;
 
entity mux_2x1 is
    port( d0, d1, s: in std_logic;
          Z : out std_logic);
end mux_2x1;
 
architecture arc of mux_2x1 is
    signal Z1, z2: std_logic;
begin
    z1 <= d0 and (not s);
    z2 <= (d1 and s);
    z <= z1 or z2;
end arc;