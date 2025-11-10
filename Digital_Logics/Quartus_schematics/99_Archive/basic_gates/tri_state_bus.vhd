library ieee;
use ieee.std_logic_1164.all;

entity tri_state_bus is
    port(
        my_in  : in std_logic_vector(7 downto 0);
        sel    : in std_logic;
        my_out : out std_logic_vector(7 downto 0)
    );
end tri_state_bus;

architecture behavior of tri_state_bus is
begin
    my_out <= "ZZZZZZZZ" when (sel = '1') else my_in;
end behavior;