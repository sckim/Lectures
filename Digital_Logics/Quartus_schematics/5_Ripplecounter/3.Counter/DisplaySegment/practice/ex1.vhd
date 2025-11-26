library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ex1 is
PORT (rst, clk : in std_logic;                    -- 입력 받는 키
		x : buffer std_logic_vector(3 downto 0));
--	    y : out std_logic_vector(6 downto 0));    -- 세그먼트로 출력
end ex1;

architecture sample of ex1 is
--	signal q : std_logic_vector (3 downto 0);    -- 입력받는 4bit 
begin
cnt : process (rst, clk)                          -- rst와 clk를 계속 확인하고 있는다.
	begin
		if rst='0' then x<= "0000";               -- rst(리셋)키가 low가 되면 출력을 "0000"으로 만든다.
		elsif (clk'event and clk='1') then       -- clk(클럭)이 상승에지일때 then 이하 동작함.. 
				x <= x+1;                       -- 그밖을 경우에는 1씩 증가
--				x<=q;
			end if;
	end process;
end sample;
