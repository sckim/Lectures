library ieee;
use ieee.std_logic_1164.all;

entity Multiplexer is 
      port( s : in std_logic_vector(1 downto 0);
            i : in std_logic_vector(3 downto 0);
            y : out std_logic);
end Multiplexer;

architecture sample of Multiplexer is
begin 
           y <= i(0) when s = "00" else
                i(1) when s = "01" else
                i(2) when s = "10" else
                i(3);
end sample;