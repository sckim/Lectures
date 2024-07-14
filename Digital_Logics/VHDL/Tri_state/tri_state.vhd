LIBRARY IEEE;
    USE ieee.std_logic_1164.ALL;

ENTITY tri_state IS
    PORT(
        a  : IN STD_LOGIC;
        sel    : IN STD_LOGIC;
        f : OUT STD_LOGIC);
END tri_state;

ARCHITECTURE behavior OF tri_state IS
BEGIN
    f <= 'Z' WHEN (sel = '1')
                ELSE a;
END behavior;