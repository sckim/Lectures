-- ALU Logic
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY addlogic IS
	PORT
	(
		nRESET								: in	std_logic;
		clk, clk2							: in	std_logic;
		
		c_and, c_add, c_dr,
		c_inpr, c_com, c_shr, 
		c_shl, e_clr, e_cme, c_inr					: in	std_logic;		
		ac, dr								: in	std_logic_vector(15 downto 0);
		inpr								: in 	std_logic_vector(7 downto 0);
		instStepMode, instStop				: in	std_logic;
		
		e_out								: out 	std_logic;
		ac_out								: out	std_logic_vector(15 downto 0)
	);
END addlogic;

ARCHITECTURE design of addlogic IS
	signal		e, e2						: std_logic;
	signal		k							: std_logic_vector(9 downto 0);
BEGIN
	k <= c_dr & c_com & c_and & c_add & c_inpr & c_shr & c_shl & e_clr & e_cme & c_inr;
	
	PROCESS (k, nRESET, clk2)
	BEGIN
		if nRESET = '0' then
			e <= '0';
		elsif falling_edge(clk2) then
			case k is 
				when "0001000000" =>		-- add
					e <= conv_std_logic_vector(conv_integer(ac) + conv_integer(dr), 17)(16);
				when "0000010000" =>		-- shr
					if instStepMode = '1' then
						if instStop = '0' then
							e <= ac(0);
						else
							e <= e;
						end if;
					else
							e <= ac(0);
					end if;
				when "0000001000" =>		-- shl
					if instStepMode = '1' then
						if instStop = '0' then
							e <= ac(15);
						else
							e <= e;
						end if;
					else
							e <= ac(15);
					end if;
					
				when "0000000100" =>		-- cle
					e <= '0';
				when "0000000010" =>		-- cme
					e <= not e2;
				when others => null;
			end case;	
		end if;	
	end process;
	e_out <= e;

	PROCESS (nRESET, clk)
	BEGIN
		if nRESET = '0' then
			e2 <= '0';
		elsif rising_edge(clk) then		-- register instance
			e2 <= e;
		end if;
	end process;

	PROCESS(k, dr, ac, inpr, e2, instStepMode, instStop)
	BEGIN
		case k is 
			when "1000000000" =>				-- c_dr
				ac_out <= dr;
			when "0100000000" =>				-- c_com
				if instStepMode = '1' then
					if instStop = '0' then
						ac_out <= not ac;
					else 
						ac_out <= ac;
					end if;
				else
					ac_out <= not ac;
				end if;	
			when "0010000000" =>				-- c_and
				if instStepMode = '1' then
					if instStop = '0' then
						ac_out <= ac and dr;
					else 
						ac_out <= ac;
					end if;
				else
					ac_out <= ac and dr;
				end if;
			when "0001000000" =>				-- c_add
				if instStepMode = '1' then
					if instStop = '0' then
						ac_out <= conv_std_logic_vector(conv_integer(ac) + conv_integer(dr), 17)(15 downto 0);
					else 
						ac_out <= ac;
					end if;
				else
					ac_out <= conv_std_logic_vector(conv_integer(ac) + conv_integer(dr), 17)(15 downto 0);
				end if;	
			when "0000100000" =>				-- c_inpr
				ac_out(7 downto 0) <= inpr;
				ac_out(15 downto 8) <= "00000000";
----------				
			when "0000010000" => --shr
				if instStepMode = '1' then
					if instStop = '0' then
						ac_out(14 downto 0) <= ac(15 downto 1);
						ac_out(15) <= e2;
					else 
						ac_out <= ac;
					end if;
				else
					ac_out(14 downto 0) <= ac(15 downto 1);
					ac_out(15) <= e2; --*****************
				end if;
----------
			when "0000001000" => --shl
				if instStepMode = '1' then
					if instStop = '0' then
						ac_out(15 downto 1) <= ac(14 downto 0);
						ac_out(0) <= e2;	
					else 
						ac_out <= ac;
					end if;
				else
					ac_out(15 downto 1) <= ac(14 downto 0);
					ac_out(0) <= e2;
				end if;
			when "0000000001" => --inr
				if instStepMode = '1' then
					if instStop = '0' then
						ac_out <= ac + "0000000000000001";
					else
						ac_out <= ac;
					end if;
				else
					ac_out <= ac + "0000000000000001";
				end if;
			when others => 
				ac_out <= "0000000000000000";
		end case;	
	end process;
END design;