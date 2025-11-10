Library ieee;
use ieee.std_logic_1164.all;

entity SR_Latch is -- ??? ??? SR_Latch_NOR? ??????.
    port (
        R : in std_logic;  -- R ?? (Active-High)
        S : in std_logic;  -- S ?? (Active-High)
        Q : out std_logic; -- Q ??
        Q_n : out std_logic -- Q_n (not Q) ??
    );
end;

architecture Behavioral of SR_Latch is
    -- NOR ???? ??? ???? ?? ?? ??
    signal Q_int : std_logic;
    signal Q_n_int : std_logic;
begin
    -- NOR ??? ?? SR ?? ??
    Q = NOR(S, Q_n)
    Q_n = NOR(R, Q)
    -- Q_int <= not (R or Q_n_int);
    -- Q_n_int <= not (S or Q_int);

    -- ?? ??? ?? ??? ??
    -- Q <= Q_int;
    -- Q_n <= Q_n_int;

end architecture Behavioral;
