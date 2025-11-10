library ieee;
use ieee.std_logic_1164.all;

entity Fulladder_tb is
end Fulladder_tb;

architecture behavior of Fulladder_tb is
    -- Component Declaration
    component Fulladder_Ver_B
        port(
            x, y, z : in std_logic;
            S, C : out std_logic
        );
    end component;
    
    -- Input Signals
    signal x_tb : std_logic := '0';
    signal y_tb : std_logic := '0';
    signal z_tb : std_logic := '0';
    
    -- Output Signals
    signal S_tb : std_logic;
    signal C_tb : std_logic;

begin
    -- Unit Under Test (UUT)
    uut: Fulladder_Ver_B port map (
        x => x_tb,
        y => y_tb,
        z => z_tb,
        S => S_tb,
        C => C_tb
    );

    -- Stimulus Process
    stim_proc: process
    begin
        -- Initialize inputs
        wait for 100 ns;
        
        -- Test Case 1: 0 + 0 + 0
        x_tb <= '0'; y_tb <= '0'; z_tb <= '0';
        wait for 100 ns;
        assert (S_tb = '0' and C_tb = '0') 
            report "Test Case 1 Failed: 0 + 0 + 0" 
            severity error;
        
        -- Test Case 2: 0 + 0 + 1
        x_tb <= '0'; y_tb <= '0'; z_tb <= '1';
        wait for 100 ns;
        assert (S_tb = '1' and C_tb = '0') 
            report "Test Case 2 Failed: 0 + 0 + 1" 
            severity error;
        
        -- Test Case 3: 0 + 1 + 0
        x_tb <= '0'; y_tb <= '1'; z_tb <= '0';
        wait for 100 ns;
        assert (S_tb = '1' and C_tb = '0') 
            report "Test Case 3 Failed: 0 + 1 + 0" 
            severity error;
        
        -- Test Case 4: 0 + 1 + 1
        x_tb <= '0'; y_tb <= '1'; z_tb <= '1';
        wait for 100 ns;
        assert (S_tb = '0' and C_tb = '1') 
            report "Test Case 4 Failed: 0 + 1 + 1" 
            severity error;
        
        -- Test Case 5: 1 + 0 + 0
        x_tb <= '1'; y_tb <= '0'; z_tb <= '0';
        wait for 100 ns;
        assert (S_tb = '1' and C_tb = '0') 
            report "Test Case 5 Failed: 1 + 0 + 0" 
            severity error;
        
        -- Test Case 6: 1 + 0 + 1
        x_tb <= '1'; y_tb <= '0'; z_tb <= '1';
        wait for 100 ns;
        assert (S_tb = '0' and C_tb = '1') 
            report "Test Case 6 Failed: 1 + 0 + 1" 
            severity error;
        
        -- Test Case 7: 1 + 1 + 0
        x_tb <= '1'; y_tb <= '1'; z_tb <= '0';
        wait for 100 ns;
        assert (S_tb = '0' and C_tb = '1') 
            report "Test Case 7 Failed: 1 + 1 + 0" 
            severity error;
        
        -- Test Case 8: 1 + 1 + 1
        x_tb <= '1'; y_tb <= '1'; z_tb <= '1';
        wait for 100 ns;
        assert (S_tb = '1' and C_tb = '1') 
            report "Test Case 8 Failed: 1 + 1 + 1" 
            severity error;
        
        -- End simulation
        wait for 100 ns;
        report "Simulation completed successfully";
        wait;
    end process;
end behavior;