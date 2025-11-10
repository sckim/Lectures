Library ieee;
Use ieee.std_logic_1164.ALL;

entity TwoInput_AndGate is
	port (InputA, InputB	: in bit;
			OutputC			: out bit);
end TwoInput_AndGate;

architecture And_logic1 of TwoInput_AndGate is
begin 
				OutputC <= InputA and InputB;
end And_logic1;






