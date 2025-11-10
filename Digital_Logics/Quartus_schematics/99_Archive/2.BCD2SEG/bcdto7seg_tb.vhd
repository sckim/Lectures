-- bcdto7seg_tb.vhd 예시 (개념 설명용)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY bcdto7seg_tb IS
END bcdto7seg_tb;

ARCHITECTURE behavior OF bcdto7seg_tb IS

    -- 시뮬레이션할 회로의 컴포넌트 선언 (bcdto7seg.bdf 에 해당하는 VHDL 넷리스트의 엔티티)
    -- Quartus가 생성하는 넷리스트 파일(.vho 또는 .vhd)을 열어 정확한 포트 이름을 확인해야 합니다.
    COMPONENT bcdto7seg IS
        PORT (
            SW0 : IN STD_LOGIC;
            SW1 : IN STD_LOGIC;
            SW2 : IN STD_LOGIC;
            SW3 : IN STD_LOGIC;
            -- VCC는 일반적으로 직접 연결되므로 여기서는 생략 가능하거나 상수 '1'로 연결
            HEX0 : OUT STD_LOGIC;
            HEX1 : OUT STD_LOGIC;
            HEX2 : OUT STD_LOGIC;
            HEX3 : OUT STD_LOGIC;
            HEX4 : OUT STD_LOGIC;
            HEX5 : OUT STD_LOGIC;
            HEX6 : OUT STD_LOGIC
        );
    END COMPONENT;

    -- 테스트 벤치 내부 신호 선언
    SIGNAL tb_SW0 : STD_LOGIC := '0';
    SIGNAL tb_SW1 : STD_LOGIC := '0';
    SIGNAL tb_SW2 : STD_LOGIC := '0';
    SIGNAL tb_SW3 : STD_LOGIC := '0';
    SIGNAL tb_HEX0 : STD_LOGIC;
    SIGNAL tb_HEX1 : STD_LOGIC;
    SIGNAL tb_HEX2 : STD_LOGIC;
    SIGNAL tb_HEX3 : STD_LOGIC;
    SIGNAL tb_HEX4 : STD_LOGIC;
    SIGNAL tb_HEX5 : STD_LOGIC;
    SIGNAL tb_HEX6 : STD_LOGIC;

BEGIN

    -- DUT (Design Under Test) 인스턴스화
    -- schematic 파일에서 추출된 엔티티(모듈)를 불러와 연결합니다.
    -- 인스턴스 이름은 "UUT" (Unit Under Test) 등으로 명명합니다.
    UUT: bcdto7seg PORT MAP (
        SW0 => tb_SW0,
        SW1 => tb_SW1,
        SW2 => tb_SW2,
        SW3 => tb_SW3,
        HEX0 => tb_HEX0,
        HEX1 => tb_HEX1,
        HEX2 => tb_HEX2,
        HEX3 => tb_HEX3,
        HEX4 => tb_HEX4,
        HEX5 => tb_HEX5,
        HEX6 => tb_HEX6
    );

    -- 입력 신호 생성 프로세스
    stim_proc: PROCESS
    BEGIN
        -- BCD 0
        tb_SW0 <= '0'; tb_SW1 <= '0'; tb_SW2 <= '0'; tb_SW3 <= '0';
        WAIT FOR 100 ns;

        -- BCD 1
        tb_SW0 <= '1'; tb_SW1 <= '0'; tb_SW2 <= '0'; tb_SW3 <= '0';
        WAIT FOR 100 ns;

        -- BCD 2
        tb_SW0 <= '0'; tb_SW1 <= '1'; tb_SW2 <= '0'; tb_SW3 <= '0';
        WAIT FOR 100 ns;

        -- BCD 3
        tb_SW0 <= '1'; tb_SW1 <= '1'; tb_SW2 <= '0'; tb_SW3 <= '0';
        WAIT FOR 100 ns;

        -- BCD 4
        tb_SW0 <= '0'; tb_SW1 <= '0'; tb_SW2 <= '1'; tb_SW3 <= '0';
        WAIT FOR 100 ns;

        -- BCD 5
        tb_SW0 <= '1'; tb_SW1 <= '0'; tb_SW2 <= '1'; tb_SW3 <= '0';
        WAIT FOR 100 ns;

        -- BCD 6
        tb_SW0 <= '0'; tb_SW1 <= '1'; tb_SW2 <= '1'; tb_SW3 <= '0';
        WAIT FOR 100 ns;

        -- BCD 7
        tb_SW0 <= '1'; tb_SW1 <= '1'; tb_SW2 <= '1'; tb_SW3 <= '0';
        WAIT FOR 100 ns;

        -- BCD 8
        tb_SW0 <= '0'; tb_SW1 <= '0'; tb_SW2 <= '0'; tb_SW3 <= '1';
        WAIT FOR 100 ns;

        -- BCD 9
        tb_SW0 <= '1'; tb_SW1 <= '0'; tb_SW2 <= '0'; tb_SW3 <= '1';
        WAIT FOR 100 ns;

        -- 시뮬레이션 종료
        WAIT UNTIL false; -- 무한 대기 (시뮬레이션 종료)
    END PROCESS;

END behavior;