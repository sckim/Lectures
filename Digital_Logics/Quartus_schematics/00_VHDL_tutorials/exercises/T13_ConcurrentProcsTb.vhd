library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity T13_ConcurrentProcsTb is
end entity;

architecture sim of T13_ConcurrentProcsTb is

    signal Uns  : unsigned(5 downto 0) := (others => '0');
    signal Mul1 : unsigned(7 downto 0);
    signal Mul2 : unsigned(7 downto 0);
    signal Mul3 : unsigned(7 downto 0);

begin

    process is
    begin

        Uns <= Uns + 1;

        wait for 10 ns;
    end process;

    -- Process multiplying Uns by 4
    process is
    begin

        -- TODO: Use bit shifting to multiply the value of Uns by 4.
        --       Assign the multiplied value to Mul1

        wait on Uns;

    end process;

    -- Equivalent process using sensitivity list
    process(Uns) is
    begin

        -- TODO: Use bit shifting to multiply the value of Uns by 4.
        --       Assign the multiplied value to Mul2
        
    end process;

    -- Equivalent process using a concurrent statement
    -- TODO: Create an equivalent process to the one above,
    --       but this time by using a concurrent statement
    --       Assign the multiplied value to Mul3

end architecture;