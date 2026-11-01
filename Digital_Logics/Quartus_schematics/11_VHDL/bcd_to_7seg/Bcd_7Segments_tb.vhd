library ieee;
use ieee.std_logic_1164.all;

entity Bcd_7Segments_tb is
end Bcd_7Segments_tb;

architecture behavior of Bcd_7Segments_tb is 
    -- Component Declaration
    component Bcd_7Segments
        port(
            bcd     : in std_logic_vector(3 downto 0);
            Display : out std_logic_vector(0 to 6)
        );
    end component;
    
    -- Input Signals
    signal bcd_in : std_logic_vector(3 downto 0);
    -- Output Signals
    signal display_out : std_logic_vector(0 to 6);

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: Bcd_7Segments port map (
        bcd => bcd_in,
        Display => display_out
    );

    -- Stimulus process
    stim_proc: process
    begin
        -- ?? ?? 0~9 ???
        bcd_in <= "0000"; wait for 100 ns; -- 0
        bcd_in <= "0001"; wait for 100 ns; -- 1
        bcd_in <= "0010"; wait for 100 ns; -- 2
        bcd_in <= "0011"; wait for 100 ns; -- 3
        bcd_in <= "0100"; wait for 100 ns; -- 4
        bcd_in <= "0101"; wait for 100 ns; -- 5
        bcd_in <= "0110"; wait for 100 ns; -- 6
        bcd_in <= "0111"; wait for 100 ns; -- 7
        bcd_in <= "1000"; wait for 100 ns; -- 8
        bcd_in <= "1001"; wait for 100 ns; -- 9
        
        -- ???? ?? ?? ???
        bcd_in <= "1010"; wait for 100 ns; -- Invalid input
        bcd_in <= "1011"; wait for 100 ns; -- Invalid input
        bcd_in <= "1111"; wait for 100 ns; -- Invalid input
        
        wait; -- ????? ??
    end process;
end behavior;