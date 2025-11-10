library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Testbench entity
entity octal_counter_tb is
end entity octal_counter_tb;

architecture testbench of octal_counter_tb is
    -- Component declaration
    component octal_counter_ud is
        port (
        clk   : in  std_logic;          -- Clock input
        reset : in  std_logic;          -- Asynchronous reset input
        up_down : in  std_logic;          -- Direction control (1 for up, 0 for down)
        counter : out std_logic_vector(2 downto 0)  -- 3-bit counter output (0 to 7)
    );
    end component;

    -- Test signals declaration
    signal clk_tb   : std_logic := '0';
    signal reset_tb : std_logic := '0';
    signal up_down_tb : std_logic := '1';
    signal counter_tb : std_logic_vector(2 downto 0);
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin
    -- DUT (Device Under Test) instantiation
    DUT: octal_counter_ud
    port map (
        clk   => clk_tb,
        reset => reset_tb,
	up_down => up_down_tb,
        counter => counter_tb
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
        
        -- Observe counterer operation
        wait for 200 ns;
        
        -- Mid-operation reset test
        reset_tb <= '1';
        wait for 10 ns;
        reset_tb <= '0';
        
	-- Observe counter operation
        wait for 50 ns;
        -- Observe counter operation for remaining time
        wait;
    end process;

end architecture testbench;