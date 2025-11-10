library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- to_integer, unsigned 등 numeric_std 패키지 사용

entity DE1SoC_tb is -- 테스트 벤치 엔티티는 포트를 가지지 않습니다.
end DE1SoC_tb;

architecture tb of DE1SoC_tb is

    -- 테스트할 DUT (Design Under Test)의 컴포넌트 선언
    component DE1SoC is
        Port (
            LEDRs: out STD_LOGIC_VECTOR(9 downto 0);
            HEX0 : out STD_LOGIC_VECTOR(6 downto 0);
            HEX1 : out STD_LOGIC_VECTOR(6 downto 0);
            SWs  : in  STD_LOGIC_VECTOR(9 downto 0);
            KEYs : in STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- DUT의 포트에 연결될 신호 선언 (signal)
    signal LEDRs_s: STD_LOGIC_VECTOR(9 downto 0);
    signal HEX0_s : STD_LOGIC_VECTOR(6 downto 0);
    signal HEX1_s : STD_LOGIC_VECTOR(6 downto 0);
    signal SWs_s  : STD_LOGIC_VECTOR(9 downto 0);
    signal KEYs_s : STD_LOGIC_VECTOR(3 downto 0);

    -- 클럭 및 리셋 신호 (필요시)
    -- current design doesn't use clock/reset, but good practice to include often
    -- signal CLK : STD_LOGIC := '0';
    -- signal RST : STD_LOGIC := '1';
    -- constant CLK_PERIOD : time := 10 ns;

begin

    -- DUT 인스턴스화 (설계 모듈 연결)
    -- Your Design Under Test (DUT)
    DUT : DE1SoC
    port map (
        LEDRs => LEDRs_s,
        HEX0  => HEX0_s,
        HEX1  => HEX1_s,
        SWs   => SWs_s,
        KEYs  => KEYs_s
    );

    -- 클럭 생성 (현재 설계에는 필요 없지만, 동기식 설계 시 필수)
    -- CLK_GEN : process
    -- begin
    --     CLK <= '0';
    --     wait for CLK_PERIOD / 2;
    --     CLK <= '1';
    --     wait for CLK_PERIOD / 2;
    -- end process CLK_GEN;

    -- 테스트 시나리오
    TEST_SCENARIO : process
    begin
        -- 초기화 (리셋 등, 현재 설계는 리셋 없음)
        -- RST <= '1';
        -- wait for 10 ns;
        -- RST <= '0';
        -- wait for 10 ns;

        -- 1. SWs 하위 4비트 -> LEDRs 하위 4비트 확인
        SWs_s <= "0000000101"; -- SWs(9 downto 0) = 5
        KEYs_s <= "0000";     -- KEYs = 0
        wait for 20 ns;       -- 신호 전파를 위한 대기
        -- 예상: LEDRs_s(3 downto 0) = "0101", LEDRs_s(9 downto 4) = "000000"
        -- HEX0_s = "0000000" (KEYs(0)='0'이므로), HEX1_s = "1000000" (0)

        -- 2. 다른 SWs 값 입력
        SWs_s <= "1111101010"; -- SWs(9 downt0 0) = 10
        KEYs_s <= "0001";     -- KEYs = 1
        wait for 20 ns;
        -- 예상: LEDRs_s(3 downto 0) = "1010", LEDRs_s(9 downto 4) = "000000"
        -- HEX0_s = "1111111" (KEYs(0)='1'이므로), HEX1_s = "1111001" (1)

        -- 3. KEYs 값 변경 (HEX1 디코딩 확인)
        KEYs_s <= "0101";     -- KEYs = 5
        wait for 20 ns;
        -- 예상: HEX1_s = "0010010" (5)

        KEYs_s <= "1010";     -- KEYs = A
        wait for 20 ns;
        -- 예상: HEX1_s = "0001000" (A)
        
        KEYs_s <= "1111";     -- KEYs = F
        wait for 20 ns;
        -- 예상: HEX1_s = "0001110" (F)

        -- 추가 테스트 시나리오를 여기에 추가합니다.
        
        wait; -- 테스트 종료 (이 process는 한 번만 실행됩니다)
    end process TEST_SCENARIO;

end tb;