library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity T16_GenericMux is
-- TODO: Create a generic port which takes the data width
--       as a constant input of type integer
generic(DataWidth : integer);
port(
-- TODO: Replace the TODO's with values calculated dynamically
--       by using our new generic data width constant
    -- Inputs
    Sig1 : in unsigned(TODO downto 0);
    Sig2 : in unsigned(TODO downto 0);
    Sig3 : in unsigned(TODO downto 0);
    Sig4 : in unsigned(TODO downto 0);

    Sel  : in unsigned(1 downto 0);

    -- Outputs
    Output : out unsigned(TODO downto 0));
end entity;

architecture rtl of T16_GenericMux is
begin

    process(Sel, Sig1, Sig2, Sig3, Sig4) is
    begin

        case Sel is
            when "00" =>
                Output <= Sig1;
            when "01" =>
                Output <= Sig2;
            when "10" =>
                Output <= Sig3;
            when "11" =>
                Output <= Sig4;
            when others => -- 'U', 'X', '-', etc.
                Output <= (others => 'X');
        end case;

    end process;

end architecture;