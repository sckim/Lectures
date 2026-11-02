LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Decimal_Counter IS
    PORT(
        clk         : IN  STD_LOGIC;                                  -- 클럭 입력
        reset       : IN  STD_LOGIC;                                  -- 비동기 리셋 (Active High)
        en          : IN  STD_LOGIC;                                  -- 카운트 인에이블 (활성화 시 카운트)
        Q           : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);               -- 4비트 카운트 값 (0000 ~ 1001)
        Count_Done  : OUT STD_LOGIC                                   -- 카운트 완료 신호 (Q=9일 때 1)
    );
END Decimal_Counter;

ARCHITECTURE Behavioral OF Decimal_Counter IS
    -- 카운트 값을 저장할 내부 신호 (레지스터)
    SIGNAL Q_internal : UNSIGNED(3 DOWNTO 0) := (OTHERS => '0'); 
BEGIN

    -- 순차 로직 (Sequential Logic) 정의
    PROCESS(clk, reset) 
    BEGIN
        -- 1. 비동기 리셋 (Async Reset)
        IF reset = '1' THEN
            Q_internal <= (OTHERS => '0'); -- 리셋 시 0으로 초기화

        -- 2. 클럭 에지 동기식 동작
        ELSIF RISING_EDGE(clk) THEN
            -- 카운트 인에이블이 '1'일 때만 동작
            IF en = '1' THEN 
                -- 9를 초과하면 0으로 롤오버 (Modulo-10)
                IF Q_internal = 9 THEN
                    Q_internal <= (OTHERS => '0');
                -- 9 이하면 1 증가
                ELSE
                    Q_internal <= Q_internal + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- 3. 출력 할당
    -- 내부 카운트 값을 외부 포트로 할당
    Q <= STD_LOGIC_VECTOR(Q_internal); 

    -- 4. 카운트 완료 (자리올림) 신호 생성
    -- 카운트 값이 9일 때 Count_Done 신호를 '1'로 설정
    Count_Done <= '1' WHEN Q_internal = 9 AND en = '1' ELSE '0'; 

END Behavioral;