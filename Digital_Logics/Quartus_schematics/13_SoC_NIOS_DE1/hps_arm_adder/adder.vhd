library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adder is
    port (
        input_a : in std_logic_vector(7 downto 0);
        input_b : in std_logic_vector(7 downto 0);
        result  : out std_logic_vector(7 downto 0)
    );
end entity;

architecture behavior of adder is
begin
    result <= input_a + input_b;
end architecture;
