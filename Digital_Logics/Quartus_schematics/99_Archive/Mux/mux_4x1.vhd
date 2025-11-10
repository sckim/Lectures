library ieee;
use ieee.std_logic_1164.all;

entity MUX_4_1a is
   port (S1, S0, A, B, C, D: in std_logic;
           Z: out std_logic);
   end MUX_4_1a;
architecture behav_MUX41a of MUX_4_1a is

begin
   P1: process (S1, S0, A, B, C, D)
   begin
     if (( not S1 and not S0 )='1') then
           Z <= A;
     elsif (( not S1 and S0) = '1') then
           Z<=B;
     elsif ((S1 and not S0) ='1') then
           Z <=C;
     else
           Z<=D;
end if;
   end process P1;
end behav_MUX41a;