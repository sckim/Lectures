-- TODO: Import the IEEE library for using std_logic

entity T10_StdLogicTb is
end entity;

architecture sim of T10_StdLogicTb is

    -- TODO: Declare a signal named "Signal1"
    --       of type std_logic with default value '0'
    
    -- TODO: Declare a signal named "Signal2" of type std_logic
    
    -- TODO: Declare a signal named "Signal3" of type std_logic

begin

    process is
    begin
        
        wait for 10 ns;
        -- TODO: Invert the value of Signal1

    end process;

    -- Driver A
    process is
    begin

        -- TODO: Constantly drive 'Z' to Signal2
        
        -- TODO: Constantly drive '0' to Signal3
        wait;

    end process;

    -- Driver B
    process(Signal1) is
    begin

        -- TODO: Drive 'Z' to both Signal2 and Signal3 if Signal1 is '0'
        --       Drive '1' to both Signal2 and Signal3 if Signal1 is not '0'
        --       
        --       Inspect the signals in the waveform and verify that the
        --       values are according to the resolution table.
        --       The resolution table is found here:
        --       https://vhdlwhiz.com/std_logic/
    
    end process;

end architecture;