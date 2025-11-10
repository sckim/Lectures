
entity barrel_shifter is
	port(	shift_in : in bit_vector(3 downto 0); 
		mode : in bit_vector(1 downto 0);
		distance : in bit_vector(1 downto 0);
		shift_out : out bit_vector(3 downto 0)); 
end barrel_shifter;

architecture behavioral of barrel_shifter is

alias rotate : bit is mode(1);
alias left : bit is mode(0);

begin


-- 동작 제어 신호 : mode(1 downto 0)
--	  mode(1) : shift mode : '1' 이면 rotate shift, '0' 이면 logical shift
-- 	  mode(0) : shift direction : '1' 이면 left shift, '0' 이면 right shift
-- 비트 이동 신호 : distance(1 downto 0), 0부터 3비트의 이동 신호 발생

process(shift_in, rotate, left, distance)
begin
	if rotate = '1' then -- rotate shift mode
		if left = '1' then -- rotate shift left mode
			case distance is
				when "00"   => shift_out(3 downto 0) <= shift_in(3 downto 0);
				when "01"   => shift_out(3 downto 0) <= shift_in(2 downto 0) & shift_in(3);
				when "10"   => shift_out(3 downto 0) <= shift_in(1 downto 0) & shift_in(3 downto 2);
				when "11"   => shift_out(3 downto 0) <= shift_in(0) & shift_in(3 downto 1);
				when others => shift_out(3 downto 0) <= shift_in(3 downto 0);
			end case;
		else -- rotate shift right mode
			case distance is
				when "00"   => shift_out(3 downto 0) <= shift_in(3 downto 0);
				when "01"   => shift_out(3 downto 0) <= shift_in(0)& shift_in(3 downto 1);
				when "10"   => shift_out(3 downto 0) <= shift_in(1 downto 0) & shift_in(3 downto 2);
				when "11"   => shift_out(3 downto 0) <= shift_in(2 downto 0) & shift_in(3);
				when others => shift_out(3 downto 0) <= shift_in(3 downto 0);
			end case;
		end if;		
	else -- logical shift mode
		if left = '1' then -- logical shift left mode
			case distance is
				when "00"   => shift_out(3 downto 0) <= shift_in(3 downto 0);
				when "01"   => shift_out(3 downto 0) <= shift_in(2 downto 0) & '0';
				when "10"   => shift_out(3 downto 0) <= shift_in(1 downto 0) & "00";
				when "11"   => shift_out(3 downto 0) <= shift_in(0) & "000";
				when others => shift_out(3 downto 0) <= shift_in(3 downto 0);
			end case;
		else -- logical shift right mode
			case distance is
				when "00"   => shift_out(3 downto 0) <= shift_in(3 downto 0);
				when "01"   => shift_out(3 downto 0) <= '0' & shift_in(3 downto 1);
				when "10"   => shift_out(3 downto 0) <= "00" & shift_in(3 downto 2);
				when "11"   => shift_out(3 downto 0) <= "000" & shift_in(3);
				when others => shift_out(3 downto 0) <= shift_in(3 downto 0);
			end case;
		end if;
	end if;
	
end process;	
end behavioral;


entity tb_barrel_shifter is
end tb_barrel_shifter ;

architecture simulation of tb_barrel_shifter is

component barrel_shifter 
	port (	shift_in : in bit_vector(3 downto 0); 
		mode : in bit_vector(1 downto 0);
		distance : in bit_vector(1 downto 0);
		shift_out : out bit_vector(3 downto 0));
end component;

signal a :  bit_vector(3 downto 0);
signal b, c :  bit_vector(1 downto 0);

begin

	a <= "0000", "0001" after 5 ns, "0010" after 10 ns, "0011" after 15 ns,
		"0100" after 20 ns, "0101" after 25 ns, "0110" after 30 ns, "0111" after 35 ns,
		"1000" after 40 ns, "1001" after 45 ns, "1010" after 50 ns, "1011" after 55 ns,
		"1100" after 60 ns, "1101" after 65 ns, "1110" after 70 ns, "1111" after 75 ns,
		"0000" after 80 ns;
	b <= "00", "01" after 5 ns, "10" after 10 ns, "11" after 15 ns,
		"00" after 20 ns, "01" after 25 ns, "10" after 30 ns, "11" after 35 ns,
		"00" after 40 ns, "01" after 45 ns, "10" after 50 ns, "11" after 55 ns,
		"00" after 60 ns, "01" after 65 ns, "10" after 70 ns, "11" after 75 ns,
		"00" after 80 ns;
	
	c <= "00", "01" after 20 ns, "10" after 40 ns, "11" after 60 ns, "00" after 80 ns;
	
	
	u0: barrel_shifter port map (shift_in=>a, mode => b, distance => c, shift_out=>open);
end simulation;