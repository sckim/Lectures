library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity T19_ProcedureTb is
end entity;

architecture sim of T19_ProcedureTb is

    -- We're slowing down the clock to speed up simulation time
    constant ClockFrequencyHz : integer := 10; -- 10 Hz
    constant ClockPeriod      : time    := 1000 ms / ClockFrequencyHz;

    signal Clk     : std_logic := '1';
    signal nRst    : std_logic := '0';
    signal Seconds : integer;
    signal Minutes : integer;
    signal Hours   : integer;

begin

    -- The Device Under Test (DUT)
    i_Timer : entity work.T19_Timer(rtl)
    generic map(ClockFrequencyHz => ClockFrequencyHz)
    port map(
        Clk     => Clk,
        nRst    => nRst,
        Seconds => Seconds,
        Minutes => Minutes,
        Hours   => Hours);

    -- Process for generating the clock
    Clk <= not Clk after ClockPeriod / 2;

    -- Testbench sequence
    process is
    begin
        wait until rising_edge(Clk);
        wait until rising_edge(Clk);

        -- Take the DUT out of reset
        nRst <= '1';

        wait;
    end process;

end architecture;