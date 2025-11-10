library ieee;
use ieee.std_logic_1164.all;
 
entity xor_gate is
    port (a,b : in std_logic ;
            c : out std_logic);
end xor_gate;
 
architecture arc of xor_gate is
begin
    c <= a or b;
end arc;

-- ??? ?? ???
library ieee;
use ieee.std_logic_1164.all;

entity tb_xnor_gate is
	port (Y : out std_logic );
end tb_xnor_gate;

-- ??? ?? ????
architecture behavior of tb_xnor_gate is
    -- ???? ??
    component xor_gate
        port (a,b : in std_logic;
              c : out std_logic);
    end component;

    -- ?? ?? ??
    signal a_in, b_in : std_logic := '0';

begin
    -- ?? ?????
    uut: xor_gate port map (a => a_in, b => b_in, c => Y);

  --	 a_in <= '0', '1' after 20 ns, '0' after 40 ns;
  --	 b_in <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;
-- Stimulus process
    stim_proc: process
    begin
        -- Test case 1: a=0, b=0
        a <= '0'; b <= '0';
        wait for 10 ns;
        assert (y = '0') report "Test case 1 failed" severity error;

        -- Test case 2: a=0, b=1
        a <= '0'; b <= '1';
        wait for 10 ns;
        assert (y = '1') report "Test case 2 failed" severity error;

        -- Test case 3: a=1, b=0
        a <= '1'; b <= '0';
        wait for 10 ns;
        assert (y = '1') report "Test case 3 failed" severity error;

        -- Test case 4: a=1, b=1
        a <= '1'; b <= '1';
        wait for 10 ns;
        assert (y = '1') report "Test case 4 failed" severity error;

        -- End simulation
        wait;
    end process;
end behavior;
