library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
    port (
        clk_50mhz : in  std_logic;  -- 50MHz 입력 클럭
        reset     : in  std_logic;  -- 비동기 리셋
        clk_1hz   : out std_logic   -- 1Hz 출력 클럭
    );
end entity clock_divider;

architecture behavioral of clock_divider is
    -- 50MHz / 2 = 25,000,000 (토글을 위한 값)
    -- 카운터 크기는 25,000,000을 저장할 수 있어야 함. (24비트 = 16,777,216, 25비트 = 33,554,432)
    constant MAX_COUNT : integer := 25000000 - 1; 

    -- 카운터 레지스터 (unsigned 타입 사용, 25비트)
    signal count_reg : unsigned(24 downto 0) := (others => '0');
    
    -- 1Hz 출력 클럭 레지스터
    signal clk_1hz_reg : std_logic := '0';

begin

    -- 카운터 및 클럭 토글 프로세스
    process (clk_50mhz, reset)
    begin
        if reset = '1' then
            -- 리셋 시 초기화
            count_reg <= (others => '0');
            clk_1hz_reg <= '0';
        elsif rising_edge(clk_50mhz) then
            -- 50MHz 클럭의 상승 엣지에서 동작
            if count_reg = MAX_COUNT then
                -- MAX_COUNT에 도달하면 (25,000,000 클럭 엣지)
                count_reg <= (others => '0'); -- 카운터 리셋
                clk_1hz_reg <= not clk_1hz_reg; -- 1Hz 클럭 토글 (0.5초마다)
            else
                -- 카운터 증가
                count_reg <= count_reg + 1;
            end if;
        end if;
    end process;
    
    -- 출력 포트 연결
    clk_1hz <= clk_1hz_reg;

end architecture behavioral;