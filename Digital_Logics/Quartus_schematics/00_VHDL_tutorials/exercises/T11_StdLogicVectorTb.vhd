library ieee;
use ieee.std_logic_1164.all;

entity T11_StdLogicVectorTb is
end entity;

architecture sim of T11_StdLogicVectorTb is

    -- TODO: Declare the following 8-bit std_logic_vectors:
    --       
    --       - downto, no initial value
    --       - downto, initial value of all zeros using aggregate assignment
    --       - downto, initial value of all ones using aggregate assignment
    --       - downto, initial value: hex AA
    --       - to, inital value: binary 10101010
    --       - downto, initial value: 1

begin

    -- Shift register
    process is
    begin

        wait for 10 ns;
        
        -- TODO: Create a looping shift register here which operates
        --       on the vector which has an inital value of 1.
        --       
        --       The shift register shall perform a barrel shift of
        --       all the bits every 10 nanoseconds.
        --
        --       First, use hard-coded bit indexes.
        --       Verified that it works in the waveform.
        --       Then, replace the hard coded values with the
        --       'left and 'right attributes.
        --       Verify that it still works.
        
    end process;

end architecture;