-- IEEE 라이브러리 포함 (std_logic 타입 사용을 위함)
library ieee;
use ieee.std_logic_1164.all;

-- 기본 게이트 회로의 입출력 정의
entity basic_gates is
   port (
       a,b : in std_logic;    -- 2개의 입력 신호 정의
       c : out std_logic      -- 1개의 출력 신호 정의
   );
end basic_gates;

-- 실제 회로의 동작을 정의하는 부분 
architecture arc of basic_gates is
begin
   c <= a and b;    -- 입력 a,b의 AND 연산 결과를 출력 c로 전달
                    -- (a=1, b=1일 때만 c=1, 나머지는 c=0)
end arc;

-- std_logic을 사용하면 다음과 같은 9가지 상태를 표현할 수 있습니다:

-- 'U': 초기화되지 않은 상태
-- 'X': 강한 미지 상태
-- '0': 강한 0
-- '1': 강한 1
-- 'Z': 하이 임피던스
-- 'W': 약한 미지 상태
-- 'L': 약한 0
-- 'H': 약한 1
-- '-': Don't care

