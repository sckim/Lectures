library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decade_counter is
    Port (
        clk_1hz   : in  STD_LOGIC;  -- 앞서 만든 1Hz 분주기 출력
        reset_n   : in  STD_LOGIC;  -- 리셋 (Active Low)
        q         : out STD_LOGIC_VECTOR(3 downto 0); -- 현재 카운트 값 (0~9)
        carry_out : out STD_LOGIC   -- 10개가 되었을 때 발생하는 펄스
    );
end decade_counter;

architecture Behavioral of decade_counter is
    -- 0부터 9까지 카운트하기 위한 내부 신호
    signal r_count : unsigned(3 downto 0) := (others => '0');
begin

    process(clk_1hz, reset_n)
    begin
        if reset_n = '0' then
            r_count <= (others => '0');
        elsif rising_edge(clk_1hz) then
            if r_count = 9 then
                r_count <= (others => '0'); -- 9 다음은 다시 0
            else
                r_count <= r_count + 1;
            end if;
        end if;
    end process;

    -- 출력 할당
    q <= std_logic_vector(r_count);

    -- carry_out: 카운트가 9일 때 '1'이 되어 다음 clk_1hz의 상승 엣지에서 
    -- 다음 단(예: 10초 단위 카운터)에 신호를 전달합니다.
    carry_out <= '1' when r_count = 9 else '0';

end Behavioral;