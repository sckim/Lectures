library ieee;
use ieee.std_logic_1164.all;

entity Fulladder_Ver_B is 
      port(x , y , z          :in std_logic;
           S , C              :out std_logic);
end Fulladder_Ver_B;

architecture sample of Fulladder_Ver_B is
begin
      S <= (not x and not y and z) or (not x and y and not z) or (x and not y and not z) or (x and y and z);
      C <= (x and y) or (x and z) or (y and z);
end sample;