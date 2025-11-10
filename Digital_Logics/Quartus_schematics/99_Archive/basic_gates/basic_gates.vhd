library ieee;
use ieee.std_logic_1164.all;
 
entity basic_gates is
    port (a,b : in std_logic ;
            c : out std_logic);
end basic_gates;
 
architecture arc of basic_gates is
begin
    c <= a and b;
end arc;