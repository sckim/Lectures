entity T02_WaitForTb is
end entity;

architecture sim of T02_WaitForTb is
begin

    process is
    begin
        -- This is the start of the process "thread"

        report "Peekaboo!";

        wait for 10 ns;

        -- The process will loop back to the start from here
    end process;

end architecture;