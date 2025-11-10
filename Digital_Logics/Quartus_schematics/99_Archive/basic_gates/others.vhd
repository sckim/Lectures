-- 방법 1: process문 사용
library ieee;
use ieee.std_logic_1164.all;

entity basic_gates is
   port (
       a,b : in std_logic;
       c : out std_logic
   );
end basic_gates;

architecture arc of basic_gates is
begin
   process(a,b)  -- a나 b가 변할 때마다 실행
   begin
       c <= a and b;
   end process;
end arc;

-- 방법 2: when-else문 사용
architecture arc2 of basic_gates is
begin
   c <= '1' when (a='1' and b='1') else '0';
end arc2;

-- 방법 3: with-select문 사용
architecture arc3 of basic_gates is
   signal inputs : std_logic_vector(1 downto 0);
begin
   inputs <= a & b;  -- a,b를 하나의 벡터로 결합
   with inputs select
       c <= '1' when "11",
            '0' when others;
end arc3;