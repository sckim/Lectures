library ieee;
use ieee.std_logic_1164.all;

ENTITY add4 IS PORT(
     A,B: 	IN	std_logic_vector(3 DOWNTO 0);
     Cin:	IN 	std_logic;
     Sum: 	OUT std_logic_vector(3 DOWNTO 0);
     Cout: 	OUT std_logic);
END add4;

ARCHITECTURE struct OF add4 IS
     COMPONENT addbit
        PORT(
          A, B, Ci : IN  std_logic;
          S, Co: OUT  std_logic);
     END COMPONENT;
     
     SIGNAL c: std_logic_vector (4 DOWNTO 0);
     BEGIN
     GEN: FOR i IN 0 TO 3 GENERATE
		U: addbit
          PORT MAP(
               A => A(i), 
               B => B(i),
               S => Sum(i),
               Ci => c(i), 
               Co => c(i+1) );
      END GENERATE GEN;
      c(0) <=Cin;
      Cout<=c(4);
END struct;

library ieee;
use ieee.std_logic_1164.all;

ENTITY addbit IS PORT(
     A, B, Ci : IN std_logic;
     S, Co: OUT std_logic);
END addbit;

ARCHITECTURE struct OF addbit IS
BEGIN
     PROCESS (A, B, Ci)
     BEGIN
          S  <= A XOR B XOR Ci;
          Co <= (A AND B) OR (B AND Ci) OR (A AND Ci);
     END PROCESS;
END struct;