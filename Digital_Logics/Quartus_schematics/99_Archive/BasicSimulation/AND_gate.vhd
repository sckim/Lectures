entity AND_gate is
	port(	A, B: in bit; 
		Y : out bit);
end;

architecture dataflow of AND_gate is

begin

	Y <= A and B ;
end;
