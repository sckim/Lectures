library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- 산술 연산을 위한 표준 라이브러리

entity ClockDivider is
    Port (
        clk_50mhz : in  STD_LOGIC; -- 50MHz 입력 클럭
        reset     : in  STD_LOGIC; -- 리셋 신호 (Active High 가정)
        clk_1hz   : out STD_LOGIC  -- 1Hz 출력 클럭
    );
end ClockDivider;

architecture Behavioral of ClockDivider is
    -- 상수 선언: 50MHz / 2 = 25,000,000
    -- 시뮬레이션 시에는 시간을 줄이기 위해 이 값을 작게(예: 5) 줄여서 테스트하는 것이 좋다.
    constant DIVISOR : integer := 25000000;
    
    -- 카운터 변수: 0부터 24,999,999까지 셀 수 있어야 함
    signal count : integer range 0 to DIVISOR - 1 := 0;
    
    -- 출력 신호를 만들기 위한 임시 레지스터
    signal temp_clk : STD_LOGIC := '0';

begin

    process(clk_50mhz, reset)
    begin
        if reset = '1' then
            -- 리셋 시 초기화
            count <= 0;
            temp_clk <= '0';
        elsif rising_edge(clk_50mhz) then
            if count = DIVISOR - 1 then
                -- 목표 값에 도달하면 카운터 초기화 및 신호 반전
                count <= 0;
                temp_clk <= not temp_clk;
            else
                -- 목표 값 미달 시 카운트 증가
                count <= count + 1;
            end if;
        end if;
    end process;

    -- 내부 신호를 실제 출력 포트에 연결
    clk_1hz <= temp_clk;

end Behavioral;