library IEEE;
use IEEE.std_logic_1164.all;
 
entity fulladder is
    port(In1,In2,c_in : in std_logic;
         sum, c_out : out std_logic);
end fulladder;
 
architecture arc of fulladder is
 
component halfadder
    port(a,b : in std_logic;
         sum, carry : out std_logic);
end component;
 
component or_2
    port(a,b : in std_logic;
         c : out std_logic);
end component;
 
signal s1, s2, s3 : std_logic;
 
begin
    H1: halfadder port map(a=>In1, b=>In2, sum=>s1, carry=>s3);
    H2: halfadder port map(a=>s1, b=>c_in, sum=>sum, carry=>s2);
    O1: or_2 port map(a=> s2, b=>s3, c=>c_out);
end arc;
 
library IEEE;
use IEEE.std_logic_1164.all;

entity halfadder is
    port (a,b : in std_logic ;
          sum,carry : out std_logic);
end halfadder;
 
architecture arc of halfadder is
begin
    sum<= a xor b;
    carry <= a and b;
end arc;
 
library IEEE;
use IEEE.std_logic_1164.all;

entity or_2 is
    port (a,b : in std_logic ;
          c : out std_logic);
end or_2;
 
architecture arc of or_2 is
begin
    c<= a or b;
end arc;