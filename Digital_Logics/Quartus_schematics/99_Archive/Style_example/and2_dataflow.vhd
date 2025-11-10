library  ieee;
use  ieee.std_logic_1164.all;

entity AND2_dataflow is 
     port (in1, in2: in std_logic;
           out1: out std_logic);
end AND2_dataflow;

architecture dataflow of AND2_dataflow is

begin
	out1 <= in1 and in2;
end dataflow;