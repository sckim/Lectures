library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider_1hz is
    Port (
        clk_50mhz : in  STD_LOGIC;  -- DE1-SoC의 50MHz 입력 (PIN_AF14 등)
        reset_n   : in  STD_LOGIC;  -- 비동기 리셋 (Active Low, KEY0 등)
        clk_1hz   : out STD_LOGIC   -- 생성된 1Hz 출력
    );
end clock_divider_1hz;

architecture Behavioral of clock_divider_1hz is
    -- 50MHz / 1Hz = 50,000,000. 
    -- 50% Duty Cycle을 위해 25,000,000번마다 반전 (0 to 24,999,999)
    constant LIMIT : integer := 25000000;
    
    signal count : integer range 0 to LIMIT - 1 := 0;
    signal r_1hz : std_logic := '0';
begin

    process(clk_50mhz, reset_n)
    begin
        if reset_n = '0' then
            count <= 0;
            r_1hz <= '0';
        elsif rising_edge(clk_50mhz) then
            if count = LIMIT - 1 then
                count <= 0;
                r_1hz <= not r_1hz; -- 신호 반전
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    clk_1hz <= r_1hz;

end Behavioral;