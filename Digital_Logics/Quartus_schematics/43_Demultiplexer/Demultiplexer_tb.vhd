LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Demultiplexer_tb IS
END Demultiplexer_tb;

ARCHITECTURE test OF Demultiplexer_tb IS
    COMPONENT Demultiplexer
        PORT (
            s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            y : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
    END COMPONENT;

    SIGNAL s_in : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL y_in : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
    uut : Demultiplexer PORT MAP(
        s => s_in,
        y => y_in);

    stim_proc : PROCESS
    BEGIN
        s_in <= "00";
        WAIT FOR 10 ns;
        s_in <= "01";
        WAIT FOR 10 ns;
        s_in <= "10";
        WAIT FOR 10 ns;
        s_in <= "11";
        WAIT FOR 10 ns;
        WAIT;
    END PROCESS;
END test;