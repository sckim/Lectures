
entity comparator is
	port(	A, B: in bit; 
		Y : out bit);
end comparator;

architecture behavioral of comparator is

begin
	-- Y <= not(A xor B) ;
process(A, B)
begin
	if (A = B) then
		Y <= '1';
	else
		Y <= '0';
	end if;
end process;	
end;


entity tb_comparator is
end tb_comparator ;

architecture simulation of tb_comparator is

component comparator 
	port (A, B: in bit; 
		Y : out bit);
end component;

signal signal_a,signal_b :  bit;

begin
	
	signal_a <= '0', '1' after 20 ns, '0' after 40 ns;
	signal_b <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;
	
	--U0 : comparator port map (A=>signal_a,B=>signal_b,Y=>open);
	--U0 : comparator port map (signal_a,signal_b,open);
	U0 : comparator port map (Y=>open,A=>signal_a,B=>signal_b);
	--U0 : comparator port map (open,signal_a,signal_b);
	
end ;