library ieee;
use ieee.std_logic_1164.all;

entity Decoder is
      port( x : in std_logic_vector(2 downto 0);
            D : out std_logic_vector(7 downto 0));
end Decoder;

architecture sample of Decoder is 
begin
      process(x)
      begin
            case x is
                      when "000" => D <= "00000001";
                      when "001" => D <= "00000010";
                      when "010" => D <= "00000100";
                      when "011" => D <= "00001000";
                      when "100" => D <= "00010000";
                      when "101" => D <= "00100000";
                      when "110" => D <= "01000000";
                      when "111" => D <= "10000000";
            end case;
      end process;
end sample;
                   