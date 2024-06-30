library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity T17_ClockedProcessTb is
end entity;

architecture sim of T17_ClockedProcessTb is

    constant ClockFrequency : integer := 100e6; -- 100 MHz
    constant ClockPeriod    : time    := 1000 ms / ClockFrequency;

    signal Clk : std_logic := '1';
    signal nRst : std_logic := '0';
    signal Input : std_logic := '0';
    signal Output : std_logic;

begin

    -- The Device Under Test (DUT)
    i_FlipFlop : entity work.T17_FlipFlop(rtl)
    port map(
        Clk    => Clk,
        nRst   => nRst,
        Input  => Input,
        Output => Output);

    -- Process for generating the clock
    Clk <= not Clk after ClockPeriod / 2;

    -- Testbench sequence
    process is
    begin
        -- Take the DUT out of reset
        nRst <= '1';

        wait for 20 ns;
        Input <= '1';
        wait for 22 ns;
        Input <= '0';
        wait for 6 ns;
        Input <= '1';
        wait for 20 ns;

        -- Reset the DUT
        nRst <= '0';

        wait;
    end process;

end architecture;