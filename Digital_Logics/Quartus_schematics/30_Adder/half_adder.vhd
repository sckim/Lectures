-- IEEE 라이브러리 포함 (디지털 로직 타입 사용)
library ieee;
use ieee.std_logic_1164.all;

-- Half Adder(반가산기) 회로의 입출력 정의
entity half_adder is
   port (
       a,b : in bit;     -- 2개의 1비트 입력
       s,c : out bit     -- s: 합(sum), c: 올림(carry) 출력
   );
end half_adder;

-- 반가산기의 동작 정의
architecture arc of half_adder is
begin
   s <= a xor b;    -- XOR 연산으로 합(sum) 계산
   c <= a and b;    -- AND 연산으로 올림(carry) 계산
                    -- 예: a=1, b=1 일 때 s=0, c=1
                    --     a=1, b=0 일 때 s=1, c=0
end arc;