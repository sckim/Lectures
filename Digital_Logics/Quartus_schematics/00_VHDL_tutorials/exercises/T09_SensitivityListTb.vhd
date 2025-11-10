entity T09_SensitivityListTb is
end entity;

architecture sim of T09_SensitivityListTb is

    signal CountUp   : integer := 0;
    signal CountDown : integer := 10;

begin

    process is
    begin

        CountUp   <= CountUp + 1;
        CountDown <= CountDown - 1;
        wait for 10 ns;

    end process;

    -- Process triggered using Wait On
    process is
    begin
    
        if CountUp = CountDown then
            report "Process A: Jackpot!";
        end if;

        wait on CountUp, CountDown;

    end process;

    -- Equivalent process using a sensitivity list    
    -- TODO: Create an equivalent process to the one above
    --       which prints out "Process B: Jackpot!"
    --       and uses a Sensitivity List (no Wait statements!)
    
end architecture;