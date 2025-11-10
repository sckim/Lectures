
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

