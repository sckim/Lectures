library ieee;
use ieee.std_logic_1164.all;
-- TODO: Import the IEEE library for using signed and unsigned types

entity T12_SignedUnsignedTb is
end entity;

architecture sim of T12_SignedUnsignedTb is

    -- TODO: Declare the following signals:
    --       
    --       - 8-bit unsigned counter with an initial value of all zeros
    --       - 8-bit signed counter with an initial value of all zeros
    --       - 4-bit unsigned with an initial value of binary 1000
    --       - 4-bit signed with an initial value of binary 1000
    --       - 8-bit unsigned with an initial value of all zeros
    --       - 8-bit signed with an initial value of all zeros

begin

    process is
    begin
    
        wait for 10 ns;

        -- Wrapping counter
        
        -- TODO: Increment the signed and unsigned counters by 1
        
        -- Adding signals
        
        -- TODO: Increment the unsigned 8-bit signal with the value of the
        --       4-bit unsigned signal
        
        -- TODO: Increment the signed 8-bit signal with the value of the
        --       4-bit signed signal

    end process;
    
end architecture;