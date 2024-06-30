entity T01_HelloWorldTb is
end entity;

architecture sim of T01_HelloWorldTb is
begin

    process is
    begin

        report "Hello World!";
        wait;

    end process;

end architecture;