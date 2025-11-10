library ieee;
use ieee.std_logic_1164.all;

-- OR 게이트 엔티티 정의
entity or_gate is
    port (
        a, b : in  std_logic;  -- 입력 신호
        c    : out std_logic   -- 출력 신호
    );
end or_gate;

-- OR 게이트 아키텍처 정의
architecture arc of or_gate is
begin
    c <= a or b;  -- OR 연산 수행
end arc;