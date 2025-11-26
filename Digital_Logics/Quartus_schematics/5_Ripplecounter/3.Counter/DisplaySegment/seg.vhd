library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity seg is
PORT (rst, clk : in std_logic;                    -- 입력 받는 키
		q : buffer std_logic_vector(3 downto 0);
	    y : out std_logic_vector(6 downto 0));    -- 세그먼트로 출력
end seg;

architecture sample of seg is
begin
cnt : process (rst, clk)                          -- rst와 clk를 계속 확인하고 있는다.
	begin
		if rst='0' then q<= "0000";               -- rst(리셋)키가 low가 되면 출력을 "0000"으로 만든다.
		elsif (clk'event and clk='1') then       -- clk(클럭)이 상승에지일때 then 이하 동작함.. 
			if q="1001" then q<="0000";          -- 10진 counter를 만들기 위해 q가 9일때 이벤트가 발생하면 q값을 0으로 만들어준다.
			else 
				q <= q+1;                       -- 그밖을 경우에는 1씩 증가
			end if;
		end if;
	end process;
	
dec : process ( q )                              -- q값을 계속 확인한다.
		begin
			case q is           -- 6543210               case ~ when 문
			   when "0000" => y <="1000000";   -- 0
			   when "0001" => y <="1111001";   -- 1
			   when "0010" => y <="0100100";   -- 2
			   when "0011" => y <="0110000";   -- 3
			   when "0100" => y <="0011001";   -- 4
			   when "0101" => y <="0010010";   -- 5
			   when "0110" => y <="0000011";   -- 6
			   when "0111" => y <="1011000";   -- 7
			   when "1000" => y <="0000000";   -- 8
			   when "1001" => y <="0011000";   -- 9
			   when others => y <= "1111111";   -- 이것이 꼭 들어가 있어야 한다.  
			end case;
		end process;
	end sample;
	
	----------   <-- 0
	--      --   
	-- 5    --   1 
	--      --
	----------   <-- 6
	--      --
 	-- 4    --   2
	--      --
	----------   <-- 3