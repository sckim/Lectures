LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY fulladder_tb IS
END fulladder_tb;
 
ARCHITECTURE behavior OF fulladder_tb IS 
    -- 테스트할 컴포넌트 선언
    COMPONENT fulladder
    PORT(
        In1, In2, c_in : IN std_logic;
        sum, c_out : OUT std_logic
    );
    END COMPONENT;
    
    -- 테스트 신호 선언
    SIGNAL In1_tb : std_logic := '0';
    SIGNAL In2_tb : std_logic := '0';
    SIGNAL c_in_tb : std_logic := '0';
    SIGNAL sum_tb : std_logic;
    SIGNAL c_out_tb : std_logic;

BEGIN
    -- 테스트할 컴포넌트 인스턴스화
    uut: fulladder PORT MAP (
        In1 => In1_tb,
        In2 => In2_tb,
        c_in => c_in_tb,
        sum => sum_tb,
        c_out => c_out_tb
    );

    -- 테스트 프로세스
    stim_proc: PROCESS
    BEGIN        

            -- 입력 신호 생성
        In1_tb <= '0', '1' after 40 ns, '0' after 80 ns;
        In2_tb <= '0', '1' after 20 ns, '0' after 40 ns, '1' after 60 ns, '0' after 80 ns;
        c_in_tb <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, 
                    '0' after 40 ns, '1' after 50 ns, '0' after 60 ns, '1' after 70 ns,
                    '0' after 80 ns;

        -- -- 가능한 모든 입력 조합 테스트 (000 ~ 111)
        -- In1_tb <= '0'; In2_tb <= '0'; c_in_tb <= '0';
        -- WAIT FOR 10 ns;
        
        -- In1_tb <= '0'; In2_tb <= '0'; c_in_tb <= '1';
        -- WAIT FOR 10 ns;
        
        -- In1_tb <= '0'; In2_tb <= '1'; c_in_tb <= '0';
        -- WAIT FOR 10 ns;
        
        -- In1_tb <= '0'; In2_tb <= '1'; c_in_tb <= '1';
        -- WAIT FOR 10 ns;
        
        -- In1_tb <= '1'; In2_tb <= '0'; c_in_tb <= '0';
        -- WAIT FOR 10 ns;
        
        -- In1_tb <= '1'; In2_tb <= '0'; c_in_tb <= '1';
        -- WAIT FOR 10 ns;
        
        -- In1_tb <= '1'; In2_tb <= '1'; c_in_tb <= '0';
        -- WAIT FOR 10 ns;
        
        -- In1_tb <= '1'; In2_tb <= '1'; c_in_tb <= '1';
        -- WAIT FOR 10 ns;

        -- 시뮬레이션 종료
        WAIT;
    END PROCESS;
END behavior;
