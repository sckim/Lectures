-- IEEE 라이브러리 포함
library ieee;
use ieee.std_logic_1164.all;

-- 전가산기(Full Adder) 정의
entity full_adder is
   port(
       In1,In2,c_in : in std_logic;    -- 2개의 입력과 이전 자리 올림
       sum, c_out : out std_logic      -- 합과 다음 자리 올림
   );
end full_adder;

-- 전가산기 구현부
architecture arc of full_adder is
   -- 반가산기 컴포넌트 선언
   component half_adder
       port(
           a,b : in std_logic;
           sum, carry : out std_logic
       );
   end component;

   -- OR 게이트 컴포넌트 선언
   component or_2
       port(
           a,b : in std_logic;
           c : out std_logic
       );
   end component;

   -- 내부 신호선 정의
   signal s1, s2, s3 : std_logic;
begin
   -- 첫 번째 반가산기: In1과 In2 덧셈
   H1: half_adder port map(a=>In1, b=>In2, sum=>s1, carry=>s3);
   -- 두 번째 반가산기: 첫 반가산기의 합과 이전 자리 올림 덧셈
   H2: half_adder port map(a=>s1, b=>c_in, sum=>sum, carry=>s2);
   -- 두 반가산기의 올림을 OR 연산하여 최종 올림 생성
   O1: or_2 port map(a=> s2, b=>s3, c=>c_out);
end arc;

library ieee;
use ieee.std_logic_1164.all;

-- 반가산기 정의 (std_logic 사용)
entity half_adder is
    port (
        a,b : in std_logic;              -- 2개의 입력
        sum,carry : out std_logic        -- 합과 올림 출력
    );
 end half_adder;
  
-- 반가산기 구현부
architecture arc of half_adder is
begin
   sum <= a xor b;      -- XOR 연산으로 합 계산
   carry <= a and b;    -- AND 연산으로 올림 계산
end arc;

library ieee;
use ieee.std_logic_1164.all;

-- OR 게이트 정의 (std_logic 사용)
entity or_2 is
port (
    a,b : in std_logic;    -- 2개의 입력
    c : out std_logic      -- OR 연산 결과 출력
);
end or_2;

-- OR 게이트 구현부
architecture arc of or_2 is
begin
   c <= a or b;    -- OR 연산 수행
end arc;
