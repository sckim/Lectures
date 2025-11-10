library ieee;
use ieee.std_logic_1164.all;
 
entity and_gate is
    port (a,b : in std_logic ;
            f : out std_logic);
end and_gate;
 
architecture arc of and_gate is
begin
    f <= a or b;
end arc;