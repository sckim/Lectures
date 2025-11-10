library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all; -- ????? ?? ??? ??
use std.textio.all;             -- ????? ?? ??? ??

entity SR_Latch_tb is
end entity SR_Latch_tb;

architecture Behavioral of SR_Latch_tb is

    -- ???? DUT (Device Under Test) ???? ??
    component SR_Latch is
        port (
            R   : in std_logic;
            S   : in std_logic;
            Q   : out std_logic;
            Q_n : out std_logic
        );
    end component SR_Latch;

    -- ????? ?? ?? ??
    signal S_tb, R_tb : std_logic := '0'; -- ?? ?? (??? ??)
    signal Q_out, Q_n_out : std_logic;    -- ?? ??

    -- ????? ?? ?? ??
    constant CLOCK_PERIOD : time := 10 ns;

begin

    -- DUT (Device Under Test) ?????
    uut: SR_Latch
        port map (
            R   => R_tb,
            S   => S_tb,
            Q   => Q_out,
            Q_n => Q_n_out
        );

    -- ?? ?? (Stimulus) ?? ????
    stim_proc: process
        variable L : line; -- ????? ??? ??? ?? ??
    begin
        -- ----------------------------------------------------
        -- ????? ?? ???
        write(L, string'("----------------------------------------------------")); writeline(output, L);
        write(L, string'("Starting SR Latch (NOR Gate) Testbench Simulation")); writeline(output, L);
        write(L, string'("----------------------------------------------------")); writeline(output, L);

        -- ?? ?? (R=0, S=0)
        -- Q, Q_n? ???? 'U' (Uninitialized)???, ? ??? ? ? ????.
        -- ??? ?? ??????? ?? ?? ? ?? ??? ?????? ?? ??????.
        R_tb <= '0';
        S_tb <= '0';
        wait for CLOCK_PERIOD;
        write(L, string'("Time: ")); write(L, now, right, 8);
        write(L, string'(" | R=0, S=0 (Hold/Initial) -> Q=")); write(L, Q_out);
        write(L, string'(", Q_n=")); write(L, Q_n_out); writeline(output, L);

        -- Test Case 1: S=1 (Set)
        S_tb <= '1';
        R_tb <= '0';
        wait for CLOCK_PERIOD;
        write(L, string'("Time: ")); write(L, now, right, 8);
        write(L, string'(" | R=0, S=1 (Set) -> Q=")); write(L, Q_out);
        write(L, string'(", Q_n=")); write(L, Q_n_out); writeline(output, L);

        -- Test Case 2: S=0, R=0 (Hold) - Set ?? ?? ??
        S_tb <= '0';
        R_tb <= '0';
        wait for CLOCK_PERIOD;
        write(L, string'("Time: ")); write(L, now, right, 8);
        write(L, string'(" | R=0, S=0 (Hold after Set) -> Q=")); write(L, Q_out);
        write(L, string'(", Q_n=")); write(L, Q_n_out); writeline(output, L);

        -- Test Case 3: R=1 (Reset)
        S_tb <= '0';
        R_tb <= '1';
        wait for CLOCK_PERIOD;
        write(L, string'("Time: ")); write(L, now, right, 8);
        write(L, string'(" | R=1, S=0 (Reset) -> Q=")); write(L, Q_out);
        write(L, string'(", Q_n=")); write(L, Q_n_out); writeline(output, L);

        -- Test Case 4: S=0, R=0 (Hold) - Reset ?? ?? ??
        S_tb <= '0';
        R_tb <= '0';
        wait for CLOCK_PERIOD;
        write(L, string'("Time: ")); write(L, now, right, 8);
        write(L, string'(" | R=0, S=0 (Hold after Reset) -> Q=")); write(L, Q_out);
        write(L, string'(", Q_n=")); write(L, Q_n_out); writeline(output, L);

        -- Test Case 5: S=1, R=1 (Forbidden State - R and S both high)
        -- NOR ??? ?? SR ????? ? ???? Q? Q_n? ?? '0'? ???.
        -- ?? ??????? ?????(metastability) ??? ?? ???? ? ???? ??? ???.
        S_tb <= '1';
        R_tb <= '1';
        wait for CLOCK_PERIOD;
        write(L, string'("Time: ")); write(L, now, right, 8);
        write(L, string'(" | R=1, S=1 (Forbidden!) -> Q=")); write(L, Q_out);
        write(L, string'(", Q_n=")); write(L, Q_n_out); writeline(output, L);

        -- Test Case 6: Forbidden ???? S=0?? ?? (R=1, S=0 -> Reset ???)
        S_tb <= '0'; -- S? ?? 0?? ??
        R_tb <= '1';
        wait for CLOCK_PERIOD;
        write(L, string'("Time: ")); write(L, now, right, 8);
        write(L, string'(" | R=1, S=0 (From Forbidden to Reset) -> Q=")); write(L, Q_out);
        write(L, string'(", Q_n=")); write(L, Q_n_out); writeline(output, L);

        -- Test Case 7: R=0, S=0 (Hold) - Reset ?? ?? ??
        R_tb <= '0';
        S_tb <= '0';
        wait for CLOCK_PERIOD;
        write(L, string'("Time: ")); write(L, now, right, 8);
        write(L, string'(" | R=0, S=0 (Hold after Reset) -> Q=")); write(L, Q_out);
        write(L, string'(", Q_n=")); write(L, Q_n_out); writeline(output, L);

        -- ----------------------------------------------------
        -- ????? ?? ???
        write(L, string'("----------------------------------------------------")); writeline(output, L);
        write(L, string'("SR Latch (NOR Gate) Testbench Simulation Ended")); writeline(output, L);
        write(L, string'("----------------------------------------------------")); writeline(output, L);

        wait; -- ????? ?? ??
    end process;

end architecture Behavioral;