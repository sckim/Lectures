
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


