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
