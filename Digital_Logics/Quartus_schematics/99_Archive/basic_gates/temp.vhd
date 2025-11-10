library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Main entity for octal counter
entity octal_counter is
    port (
        clk   : in  std_logic;          -- Clock input
        reset : in  std_logic;          -- Asynchronous reset input
        count : out std_logic_vector(2 downto 0)  -- 3-bit counter output (0 to 7)
    );
end entity;

architecture behavioral of octal_counter is
    signal counter: std_logic_vector(2 downto 0) := "000";  -- Internal 3-bit counter
begin
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= "000";            -- Reset counter to 0
        elsif rising_edge(clk) then
            if counter = "111" then      -- Check if counter reached 7
                counter <= "000";        -- Reset to 0 after reaching 7
            else
                counter <= counter + 1;  -- Increment counter
            end if;
        end if;
    end process;

    count <= counter;  -- Output the current counter value
end architecture behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Testbench entity
entity octal_counter_tb is
end entity octal_counter_tb;

architecture testbench of octal_counter_tb is
    -- Component declaration
    component octal_counter is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            count : out std_logic_vector(2 downto 0)
        );
    end component;

    -- Test signals declaration
    signal clk_tb   : std_logic := '0';
    signal reset_tb : std_logic := '0';
    signal count_tb : std_logic_vector(2 downto 0);
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin
    -- DUT (Device Under Test) instantiation
    DUT: octal_counter
    port map (
        clk   => clk_tb,
        reset => reset_tb,
        count => count_tb
    );

    -- Clock generation process
    clk_process: process
    begin
        while now < 200 ns loop  -- Run simulation for 200ns
            clk_tb <= '0';
            wait for CLK_PERIOD/2;
            clk_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Test scenario
    stimulus_process: process
    begin
        -- Initial reset
        reset_tb <= '1';
        wait for 15 ns;
        reset_tb <= '0';
        
        -- Observe counter operation
        wait for 100 ns;
        
        -- Mid-operation reset test
        reset_tb <= '1';
        wait for 10 ns;
        reset_tb <= '0';
        
        -- Observe counter operation for remaining time
        wait;
    end process;

end architecture testbench;