library ieee;
use ieee.std_logic_1164.all;

entity or_gate_tb is
end entity or_gate_tb;

architecture simulation of or_gate_tb is

component or_gate is
    port (
        a : in std_logic;
        b : in std_logic;
        y : out std_logic
    );
end component or_gate;

signal a_tb, b_tb : std_logic := '0';
signal y_tb : std_logic;

begin
    u0: or_gate
        port map (
            a => a_tb,
            b => b_tb,
            y => y_tb
        );

    a_tb <= '0', '1' after 20 ns, '0' after 40 ns;
    b_tb <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;


    -- process
    -- begin
    --     -- Test case 1: a = '0', b = '0'
    --     a_tb <= '0';
    --     b_tb <= '0';
    --     wait for 10 ns;
        
    --     -- Test case 2: a = '0', b = '1'
    --     a_tb <= '0';
    --     b_tb <= '1';
    --     wait for 10 ns;

    --     -- Test case 3: a = '1', b = '0'
    --     a_tb <= '1';
    --     b_tb <= '0';
    --     wait for 10 ns;

    --     -- Test case 4: a = '1', b = '1'
    --     a_tb <= '1';
    --     b_tb <= '1';
    --     wait for 10 ns;

    --     -- End simulation
    --     wait;
    -- end process;

end architecture;