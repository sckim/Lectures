
entity AND_gate is
	port(	A, B: in bit; 
		Y : out bit);
end;

architecture dataflow of AND_gate is

begin

	Y <= A and B ;
	
end;

entity tb_AND_gate is
	-- port (Y : out bit) ;
end tb_AND_gate ;

architecture simulation of tb_AND_gate is

component AND_gate 
	port (A, B: in bit; 
		Y : out bit);
end component;

signal a,b :  bit;

begin
	
	A <= '0', '1' after 20 ns, '0' after 40 ns;
	B <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;
	
	--U0 : AND_gate port map (A=>A,B=>B,Y=>Y);
	U0 : AND_gate port map (A=>A,B=>B,Y=>open);
	
end ;
