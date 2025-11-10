library ieee;
use ieee.std_logic_1164.all;

-- Testbench entity declaration (no ports)
entity or_gate_tb is
	port( Y: out std_logic);
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

begin
    -- OR gate instance creation
    uut: or_gate port map (
        a => a_test,
        b => b_test,
        c => Y
    );

    -- Generate test signals
    a_test <= '0', '0' after 10 ns, '1' after 30 ns, '1' after 50 ns;
    b_test <= '0', '1' after 20 ns, '0' after 40 ns, '1' after 60 ns;

--    -- Verify test results
--    assert_proc: process
--    begin
--        wait for 15 ns;  -- Verify test case 1
--        assert (c_test = '0') 
--            report "Test failed: When a=0, b=0, c should be 0"
--            severity error;
--            
--        wait for 10 ns;  -- Verify test case 2
--        assert (c_test = '1')
--            report "Test failed: When a=0, b=1, c should be 1"
--            severity error;
--            
--        wait for 10 ns;  -- Verify test case 3
--        assert (c_test = '1')
--            report "Test failed: When a=1, b=0, c should be 1"
--            severity error;
--            
--        wait for 10 ns;  -- Verify test case 4
--        assert (c_test = '1')
--            report "Test failed: When a=1, b=1, c should be 1"
--            severity error;
--            
--        report "Test completed";
--        wait;
--    end process;
end behavior;
