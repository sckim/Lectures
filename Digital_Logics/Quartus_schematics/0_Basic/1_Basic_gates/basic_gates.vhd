library ieee;
use ieee.std_logic_1164.all;

-- AND 게이트
entity and_gate is
    port (a, b : in std_logic;
          c : out std_logic);
end and_gate;

architecture behav of and_gate is
begin
    c <= a and b;
end behav;

library ieee;
use ieee.std_logic_1164.all;

-- OR 게이트
entity or_gate is
    port (a, b : in std_logic;
          c : out std_logic);
end or_gate;

architecture behav of or_gate is
begin
    c <= a or b;
end behav;

library ieee;
use ieee.std_logic_1164.all;

-- NOT 게이트
entity not_gate is
    port (a : in std_logic;
          c : out std_logic);
end not_gate;

architecture behav of not_gate is
begin
    c <= not a;
end behav;

library ieee;
use ieee.std_logic_1164.all;

-- NAND 게이트
entity nand_gate is
    port (a, b : in std_logic;
          c : out std_logic);
end nand_gate;

architecture behav of nand_gate is
begin
    c <= not (a and b);
end behav;

library ieee;
use ieee.std_logic_1164.all;

-- NOR 게이트
entity nor_gate is
    port (a, b : in std_logic;
          c : out std_logic);
end nor_gate;

architecture behav of nor_gate is
begin
    c <= not (a or b);
end behav;

library ieee;
use ieee.std_logic_1164.all;

-- XOR 게이트
entity xor_gate is
    port (a, b : in std_logic;
          c : out std_logic);
end xor_gate;

architecture behav of xor_gate is
begin
    c <= a xor b;
end behav;

library ieee;
use ieee.std_logic_1164.all;

entity tri_state is
port(
    a  : in std_logic;
    sel: in std_logic;
    c : out std_logic);
end tri_state;

architecture behavior of tri_state is
begin
    c <= 'Z' when (sel = '0')
                else a;
end behavior;