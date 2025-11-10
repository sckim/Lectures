library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity T18_Timer is
generic(ClockFrequencyHz : integer);
port(
    Clk     : in std_logic;
    nRst    : in std_logic; -- Negative reset
    Seconds : inout integer;
    Minutes : inout integer;
    Hours   : inout integer);
end entity;

architecture rtl of T18_Timer is

    -- Signal for counting clock periods
    signal Ticks : integer;
    
begin

    process(Clk) is
    begin
        if rising_edge(Clk) then

            -- If the negative reset signal is active
            if nRst = '0' then
            
                -- TODO: Reset all the outputs and the Ticks signal

            else

                -- True once every second
                if Ticks = ClockFrequencyHz - 1 then
                    Ticks <= 0;
            
                    -- TODO: Implement the Seconds, Minutes and Hours counter
                    --       here by using nested If-Then-Else statements.
            
                else
                    Ticks <= Ticks + 1;
                end if;
            
            end if;
        end if;
    end process;

end architecture;