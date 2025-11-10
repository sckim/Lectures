
entity decoder3x8 is
	port(	A : in bit_vector(2 downto 0); 
		Y : out bit_vector(7 downto 0)); 
end decoder3x8;

architecture behavioral of decoder3x8 is

begin

process(A)
begin
	case A is
		when "000" => Y <= "00000001";
		when "001" => Y <= "00000010";
		when "010" => Y <= "00000100";
		when "011" => Y <= "00001000";
		when "100" => Y <= "00010000";
		when "101" => Y <= "00100000";
		when "110" => Y <= "01000000";
		when "111" => Y <= "10000000";
		when others=> Y <= "00000001";
	end case;
end process;	
end behavioral;


entity tb_decoder3x8 is
end tb_decoder3x8 ;

architecture simulation of tb_decoder3x8 is

component decoder3x8 
	port (	A : in bit_vector(2 downto 0); 
		Y : out bit_vector(7 downto 0));
end component;

signal signal_a :  bit_vector(2 downto 0);

begin

	signal_a <= "000", "001" after 5 ns, "010" after 10 ns, "011" after 15 ns,
		"100" after 20 ns, "101" after 25 ns, "110" after 30 ns, "111" after 35 ns,
		"000" after 40 ns, "001" after 45 ns, "010" after 50 ns, "011" after 55 ns,
		"100" after 60 ns, "101" after 65 ns, "110" after 70 ns, "111" after 75 ns,
		"000" after 80 ns;
	
	u0: decoder3x8 port map (A=>signal_a, Y=>open);
end ;