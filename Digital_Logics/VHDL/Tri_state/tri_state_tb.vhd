library ieee;
use ieee.std_logic_1164.all ;

entity tri_state_tb is
	port (F : out std_logic) ;
end  tri_state_tb ;

architecture simulation of  tri_state_tb is

component  tri_state 
	port(a : in std_logic;
		 sel : in std_logic;
		  f : out std_logic);
end component;

signal A, C :  std_logic;
begin
--     process
--     begin
--         -- 초기 값 설정
--         A <= '0';
--         C <= '0';
        
--         -- A 신호 생성
--         wait for 10 ns;
--         A <= '0';
--         C <= '1';
        
--         wait for 10 ns;
--         A <= '1';
--         C <= '0';
        
--         wait for 10 ns;
--         A <= '1';
--         C <= '1';
        
--         -- 프로세스 종료
--         wait;
--     end process;

    A <= '0', '1' after 20 ns, '0' after 40 ns;
	C <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;

    U0 : tri_state port map (A, C, F);	
end architecture;