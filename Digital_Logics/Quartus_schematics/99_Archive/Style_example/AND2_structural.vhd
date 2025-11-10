library  ieee;
use  ieee.std_logic_1164.all;

entity AND2_structural is
     port (in1, in2: in std_logic;
           out1: out std_logic);
end AND2_structural;

architecture structure of AND2_structural is
component AND2_dataflow -- AND2 component declaration
     port (in1, in2: in std_logic;
           out1: out std_logic);
end component;

begin
	U1: AND2_dataflow port map(in1, in2, out1);
end structure;