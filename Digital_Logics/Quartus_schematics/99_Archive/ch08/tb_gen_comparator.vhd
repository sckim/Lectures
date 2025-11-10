
entity comparator is
	generic(N : integer := 4);
	port(	A : in bit_vector(N-1 downto 0); 
		B : in bit_vector(N-1 downto 0); 
		A_EQ_B, A_GT_B, A_LT_B, A_GE_B, A_LE_B : out bit);
end comparator;

architecture behavioral of comparator is

begin
process(A, B)
begin
	if (A = B) then
		A_EQ_B <= '1';
	else
		A_EQ_B <= '0';
	end if;
	
	if (A > B) then
		A_GT_B <= '1';
	else
		A_GT_B <= '0';
	end if;
	
	if (A < B) then
		A_LT_B <= '1';
	else
		A_LT_B <= '0';
	end if;
	
	if (A >= B) then
		A_GE_B <= '1';
	else
		A_GE_B <= '0';
	end if;
	
	if (A <= B) then
		A_LE_B <= '1';
	else
		A_LE_B <= '0';
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
		A_EQ_B, A_GT_B, A_LT_B, A_GE_B, A_LE_B : out bit);
end component;

constant M : integer := 2;
signal a, b :  bit_vector(M-1 downto 0);

begin
	
	a <= "00", "01" after 5 ns, "10" after 10 ns, "11" after 15 ns,
		"00" after 20 ns, "01" after 25 ns, "10" after 30 ns, "11" after 35 ns,
		"00" after 40 ns, "01" after 45 ns, "10" after 50 ns, "11" after 55 ns,
		"00" after 60 ns, "01" after 65 ns, "10" after 70 ns, "11" after 75 ns,
		"00" after 80 ns;
	
	b <= "00", "01" after 20 ns, "10" after 40 ns, "11" after 60 ns, "00" after 80 ns;
	
	u0: comparator 
		generic map(N => 2) 
		port map (A=>a,B=>b,A_EQ_B=>open, A_GT_B=>open, A_LT_B=>open,
 				A_GE_B=>open, A_LE_B=>open);
end ;

