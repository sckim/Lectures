library ieee;
use ieee.std_logic_1164.all;

entity basic_gates_tb is
end basic_gates_tb;

architecture simulation of basic_gates_tb is
    component and_gate
        port (a, b : in std_logic;
              c : out std_logic);
    end component;

    component or_gate
        port (a, b : in std_logic;
              c : out std_logic);
    end component;

    component not_gate
        port (a : in std_logic;
              c : out std_logic);
    end component;

    component nand_gate
        port (a, b : in std_logic;
              c : out std_logic);
    end component;

    component nor_gate
        port (a, b : in std_logic;
              c : out std_logic);
    end component;

    component xor_gate
        port (a, b : in std_logic;
              c : out std_logic);
    end component;

    component  tri_state 
        port(a : in std_logic;
             sel : in std_logic;
             c : out std_logic);
    end component;

    signal A, B : std_logic;
    signal Y_AND, Y_OR, Y_NOT, Y_NAND, Y_NOR, Y_XOR, Y_TRISTATE : std_logic;

begin
    -- 입력 신호 생성
    A <= '0', '1' after 20 ns, '0' after 40 ns;
	 B <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;

    -- 게이트 인스턴스화
    U_AND  : and_gate  port map (a => A, b => B, c => Y_AND);
    U_OR   : or_gate   port map (a => A, b => B, c => Y_OR);
    U_NOT  : not_gate  port map (a => A, c => Y_NOT);
    U_NAND : nand_gate port map (a => A, b => B, c => Y_NAND);
    U_NOR  : nor_gate  port map (a => A, b => B, c => Y_NOR);
    U_XOR  : xor_gate  port map (a => A, b => B, c => Y_XOR);
    U_TRISTATE : tri_state port map (a => A, sel => B, c => Y_TRISTATE);	

end simulation;