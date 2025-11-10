-- 전가산기 테스트 벤치
library IEEE;
use IEEE.std_logic_1164.all;

entity full_adder_tb is
end full_adder_tb;

architecture behavior of full_adder_tb is
   -- 테스트할 컴포넌트 선언
   component full_adder
       port(
           In1,In2,c_in : in std_logic;
           sum, c_out : out std_logic
       );
   end component;
   
   -- 테스트 신호 선언
   signal In1_tb, In2_tb, c_in_tb : std_logic;
   signal sum_tb, c_out_tb : std_logic;
   
begin
   -- 테스트할 회로 인스턴스화
   uut: full_adder port map (
       In1 => In1_tb,
       In2 => In2_tb,
       c_in => c_in_tb,
       sum => sum_tb,
       c_out => c_out_tb
   );
   
   -- 테스트 프로세스
   stim_proc: process
   begin
       -- 모든 가능한 입력 조합 테스트
       -- 000
       In1_tb <= '0'; In2_tb <= '0'; c_in_tb <= '0';
       wait for 100 ns;
       
       -- 001
       In1_tb <= '0'; In2_tb <= '0'; c_in_tb <= '1';
       wait for 100 ns;
       
       -- 010
       In1_tb <= '0'; In2_tb <= '1'; c_in_tb <= '0';
       wait for 100 ns;
       
       -- 011
       In1_tb <= '0'; In2_tb <= '1'; c_in_tb <= '1';
       wait for 100 ns;
       
       -- 100
       In1_tb <= '1'; In2_tb <= '0'; c_in_tb <= '0';
       wait for 100 ns;
       
       -- 101
       In1_tb <= '1'; In2_tb <= '0'; c_in_tb <= '1';
       wait for 100 ns;
       
       -- 110
       In1_tb <= '1'; In2_tb <= '1'; c_in_tb <= '0';
       wait for 100 ns;
       
       -- 111
       In1_tb <= '1'; In2_tb <= '1'; c_in_tb <= '1';
       wait for 100 ns;
       
       wait; -- 시뮬레이션 종료
   end process;
end behavior;