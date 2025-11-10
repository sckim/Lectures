library ieee;
use ieee.std_logic_1164.all;

entity Fulladder_Ver_B is 
    port(x, y, z     : in std_logic;
         S, C        : out std_logic);
end Fulladder_Ver_B;

architecture structure of Fulladder_Ver_B is
    -- 기본 게이트 컴포넌트 선언
    component and_gate is
        port(a, b : in std_logic;
             c    : out std_logic);
    end component;

    component or_gate is
        port(a, b : in std_logic;
             c    : out std_logic);
    end component;

    component not_gate is
        port(a : in std_logic;
             b : out std_logic);
    end component;

    -- 내부 신호 선언
    signal not_x, not_y, not_z : std_logic;
    signal and1, and2, and3, and4 : std_logic;  -- S를 위한 AND 게이트 출력
    signal or1, or2, or3 : std_logic;           -- S를 위한 OR 게이트 출력
    signal and5, and6, and7 : std_logic;        -- C를 위한 AND 게이트 출력
    signal or4, or5 : std_logic;                -- C를 위한 OR 게이트 출력

begin
    -- NOT 게이트 인스턴스
    not1: not_gate port map(a => x, b => not_x);
    not2: not_gate port map(a => y, b => not_y);
    not3: not_gate port map(a => z, b => not_z);

    -- S 출력을 위한 게이트 인스턴스
    and_s1: and_gate port map(a => not_x, b => not_y, c => and1);
    and_s2: and_gate port map(a => and1, b => z, c => and2);

    and_s3: and_gate port map(a => not_x, b => y, c => and3);
    and_s4: and_gate port map(a => and3, b => not_z, c => and4);

    and_s5: and_gate port map(a => x, b => not_y, c => and5);
    and_s6: and_gate port map(a => and5, b => not_z, c => and6);

    and_s7: and_gate port map(a => x, b => y, c => and7);
    and_s8: and_gate port map(a => and7, b => z, c => or3);

    or_s1: or_gate port map(a => and2, b => and4, c => or1);
    or_s2: or_gate port map(a => and6, b => or3, c => or2);
    or_s3: or_gate port map(a => or1, b => or2, c => S);

    -- C 출력을 위한 게이트 인스턴스
    and_c1: and_gate port map(a => x, b => y, c => and5);
    and_c2: and_gate port map(a => x, b => z, c => and6);
    and_c3: and_gate port map(a => y, b => z, c => and7);

    or_c1: or_gate port map(a => and5, b => and6, c => or4);
    or_c2: or_gate port map(a => or4, b => and7, c => C);

end structure;