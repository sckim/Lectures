library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Fulladder_Ver_C is
      port( x , y , z          :in integer range 0 to 1;
            S , C              :out std_logic);
end Fulladder_Ver_C;

architecture sample of Fulladder_Ver_C is
      signal sum         : std_logic_vector(1 downto 0);
begin 
      process(x,y,z)
      begin
            sum <= conv_std_logic_vector( x + y + z , 2);
      end process;
      S <= sum(0);
      C <= sum(1);
end sample;     