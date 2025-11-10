library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Main entity for octal counter
entity octal_counter_ud is
    port (
        clk   : in  std_logic;          -- Clock input
        reset : in  std_logic;          -- Asynchronous reset input
        up_down : in  std_logic;          -- Direction control (1 for up, 0 for down)
        counter : out std_logic_vector(2 downto 0)  -- 3-bit counter output (0 to 7)
    );
end entity;

architecture behavioral of octal_counter_ud is
    signal counter: std_logic_vector(2 downto 0) := "000";  -- Internal 3-bit counter
begin
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= "000";            -- Reset counter to 0
        elsif rising_edge(clk) then
            if up_down = '1' then
                if counter = "111" then  -- If counting up and reached max (7)
                    counter <= "000";    -- Wrap around to 0
                else
                    counter <= counter + 1;  -- Increment counter
                end if;
            else
                if counter = "000" then  -- If counting down and reached min (0)
                    counter <= "111";    -- Wrap around to 7
                else
                    counter <= counter - 1;  -- Decrement counter
                end if;
	    end if;
        end if;
    end process;

    counter <= counter;  -- Output the current counter value
end architecture behavioral;
