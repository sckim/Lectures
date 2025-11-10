library ieee;
use ieee.std_logic_1164.all;

-- 테스트 벤치 엔티티 정의
entity tb_basic_gate is
end tb_basic_gate;

-- 테스트 벤치 아키텍처 정의
architecture behavior of tb_basic_gate is
    -- OR 게이트 컴포넌트 선언
    component or_gate
        port (
            a, b : in  std_logic;
            c    : out std_logic
        );
    end component;

    -- 테스트용 입력 및 출력 신호 선언
    signal a_in, b_in : std_logic := '0';
    signal y_out : std_logic;

begin
    -- OR 게이트 인스턴스 생성
    uut: or_gate port map (
        a => a_in,
        b => b_in, 
        c => y_out
    );

    a_in <= '0', '1' after 20 ns, '0' after 40 ns;
	 b_in <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;
end behavior;

