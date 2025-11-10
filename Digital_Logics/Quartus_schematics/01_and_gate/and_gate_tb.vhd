library ieee;
use ieee.std_logic_1164.all;

entity and_gate_tb is
end and_gate_tb;

architecture simulation of and_gate_tb is
    component and_gate 
        port (a, b: in std_logic; 
             c : out std_logic);
    end component;
    
    -- 테스트벤치 신호: tb_ 접두사 사용
    signal tb_a, tb_b : std_logic;
    signal tb_y : std_logic;
    
begin	
    tb_a <= '0', '1' after 20 ns, '0' after 40 ns;
    tb_b <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;
    
    -- 포트 맵: 컴포넌트 포트 => 테스트벤치 신호
    U0 : and_gate port map (a=>tb_a, b=>tb_b, c=>tb_y);
end simulation;