LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Demultiplexer IS
     PORT (
          s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          y : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END Demultiplexer;

ARCHITECTURE sample OF Demultiplexer IS
BEGIN
     PROCESS (s)
     BEGIN
          CASE s IS
               WHEN "00" =>
                    y <= "0001";
               WHEN "01" =>
                    y <= "0010";
               WHEN "10" =>
                    y <= "0100";
               WHEN "11" =>
                    y <= "1000";
               WHEN OTHERS =>
                    y <= "0000";
          END CASE;
     END PROCESS;
END sample;