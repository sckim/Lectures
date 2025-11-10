library ieee;
use ieee.std_logic_1164.all;

-- Testbench entity declaration (no ports)
entity or_gate_tb is
end or_gate_tb;

architecture behavior of or_gate_tb is
    -- OR gate component declaration
    component or_gate
        port (
            a, b : in  std_logic;
            c    : out std_logic
        );
    end component;

    -- Test signal declaration
    signal a_test : std_logic := '0';
    signal b_test : std_logic := '0';
    signal c_test : std_logic;

begin
    -- OR gate instance creation
    uut: or_gate port map (
        a => a_test,
        b => b_test,
        c => c_test
    );

    -- Test process
    stim_proc: process
    begin
        -- Test case 1: a=0, b=0
        a_test <= '0';
        b_test <= '0';
        wait for 100 ns;
        assert (c_test = '0') 
            report "Test failed: When a=0, b=0, c should be 0"
            severity error;

        -- Test case 2: a=0, b=1
        a_test <= '0';
        b_test <= '1';
        wait for 100 ns;
        assert (c_test = '1')
            report "Test failed: When a=0, b=1, c should be 1"
            severity error;

        -- Test case 3: a=1, b=0
        a_test <= '1';
        b_test <= '0';
        wait for 100 ns;
        assert (c_test = '1')
            report "Test failed: When a=1, b=0, c should be 1"
            severity error;

        -- Test case 4: a=1, b=1
        a_test <= '1';
        b_test <= '1';
        wait for 100 ns;
        assert (c_test = '1')
            report "Test failed: When a=1, b=1, c should be 1"
            severity error;

        -- End simulation
        a_test <= '0';
        b_test <= '0';
        wait for 100 ns;
        report "Test completed";
        wait;
    end process;
end behavior;
