library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity T12_SignedUnsignedTb is
end entity;

architecture sim of T12_SignedUnsignedTb is

    signal UnsCnt : unsigned(7 downto 0) := (others => '0');
    signal SigCnt : signed(7 downto 0)   := (others => '0');

    signal Uns4   : unsigned(3 downto 0) := "1000";
    signal Sig4   : signed(3 downto 0)   := "1000";

    signal Uns8   : unsigned(7 downto 0) := (others => '0');
    signal Sig8   : signed(7 downto 0)   := (others => '0');

begin

    process is
    begin

        wait for 10 ns;

        -- Wrapping counter
        UnsCnt <= UnsCnt + 1;
        SigCnt <= SigCnt + 1;

        -- Adding signals
        Uns8 <= Uns8 + Uns4;
        Sig8 <= Sig8 + Sig4;

    end process;
end architecture;