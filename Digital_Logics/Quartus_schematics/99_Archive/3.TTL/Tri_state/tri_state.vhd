LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;

--ENTITY tri_state IS
--    PORT(
--        my_in  : IN STD_LOGIC;
--        sel    : IN STD_LOGIC;
--        my_out : OUT STD_LOGIC);
--END tri_state;

--ARCHITECTURE behavior OF tri_state IS
--BEGIN
--    my_out <= 'Z' WHEN (sel = '1')
--                  ELSE my_in;
--END behavior;

ENTITY tri_state IS
    PORT(
        my_in  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        sel    : IN STD_LOGIC;
        my_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END tri_state;

ARCHITECTURE behavior OF tri_state IS
BEGIN
    my_out <= "ZZZZZZZZ"
    WHEN (sel = '1')
    ELSE my_in;
END behavior;

