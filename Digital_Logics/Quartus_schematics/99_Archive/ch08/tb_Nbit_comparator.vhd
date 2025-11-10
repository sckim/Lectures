
entity comparator is
	--generic(N : integer);
	generic(N : integer := 2);
	port(	A : in bit_vector(N-1 downto 0); 
		B : in bit_vector(N-1 downto 0); 
		Y : out bit);
end comparator;

architecture behavioral of comparator is

begin

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
	generic(N : integer);
	port (A : in bit_vector(N-1 downto 0); 
		B : in bit_vector(N-1 downto 0); 
		Y : out bit);
end component;

signal signal_a,signal_b :  bit_vector(3 downto 0);

begin
	
	signal_a <= "0000", "1111" after 20 ns, "0000" after 40 ns;
	signal_b <= "0000", "1111" after 10 ns, "0000" after 20 ns, "1111" after 30 ns, "0000" after 40 ns;
	
	u0: comparator 
		generic map(N => 4) 
		port map (A=>signal_a,B=>signal_b,Y=>open);
end ;