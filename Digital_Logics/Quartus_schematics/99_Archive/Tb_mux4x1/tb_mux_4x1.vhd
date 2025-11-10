
entity mux_4x1 is
	port(	a, b, c, d: in bit; 
		sel : in bit_vector(1 downto 0);
		q : out bit);
end;

architecture with_select of mux_4x1 is

begin

--with sel select
--	q <= a when "00",
--		b when "01",
--		c when "10",
--		-- c when "11",
--		d when "11",
--		a when others;

process(a,b,c,d,sel)
begin
	if sel = "00" then
		q <= a;
	elsif sel = "01" then
		q <= b;
	elsif sel = "10" then
		q <= c;
	elsif sel = "11" then
		q <= d;
	else
		q <= a;
	end if;
end process;

end;

entity tb_mux_4x1 is
end tb_mux_4x1 ;

architecture simulation of tb_mux_4x1 is

component mux_4x1 
	port (	a, b, c, d: in bit; 
		sel : bit_vector(1 downto 0);
		q : out bit);
end component;

signal a,b,c,d :  bit;
signal sel :  bit_vector(1 downto 0);

begin
	
	A <= '0', '1' after 5 ns, '0' after 10 ns, '1' after 15 ns, '0' after 20 ns, '1' after 80 ns;
	B <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;
	C <= '0', '1' after 15 ns, '0' after 30 ns, '1' after 45 ns, '0' after 60 ns;
	D <= '0', '1' after 20 ns, '0' after 40 ns, '1' after 60 ns, '0' after 70 ns;
	SEL <= "00", "01" after 20 ns, "10" after 40 ns, "11" after 60 ns, "00" after 80 ns;

	
	U0 : mux_4x1 port map (A=>A,B=>B,C=>C, D=>D, SEL=> SEL, Q=>open);
	
end ;