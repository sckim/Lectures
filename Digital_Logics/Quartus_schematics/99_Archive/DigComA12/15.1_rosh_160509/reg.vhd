-- Instruction decoder
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY reg IS
	PORT(	nRESET				: in	std_logic;
			clk0					: in	std_logic;
			clk					: IN	std_logic;
		
			ar_ld, ar_inr, ar_clr,
			pc_ld, pc_inr, pc_clr,
			dr_ld, dr_inr,
			ac_ld, ac_inr, ac_clr,
			ir_ld, tr_ld		: in 	std_logic; 
		

			x						: in	std_logic_vector(7 downto 1);
			ac_in					: in	std_logic_vector(15 downto 0);
			instStepMode, instStop	: in	std_logic;
		
			ac_out, dr_out		:	out	std_logic_vector(15 downto 0);
			ir_dec_out			:	out	std_logic_vector(2 downto 0);
			ar_out				:	out std_logic_vector(11 downto 0);
			ir_out				: 	out std_logic_vector(15 downto 0);
			pc_out				: 	out std_logic_vector(11 downto 0);
			I_out					: 	out std_logic;
			address				:	out std_logic_vector(11 downto 0);
			cb  					: 	inout std_logic_vector(15 downto 0);
			ac_value				:	out std_logic_vector(15 downto 0);
			tr_out				:	out std_logic_vector(15 downto 0));
END reg;

ARCHITECTURE regs_arch of reg IS
	signal	ar, pc	 		: std_logic_vector(11 downto 0);
	signal	dr, ac, ir, tr	: std_logic_vector(15 downto 0);
	signal	cb_node			: std_logic_vector(15 downto 0);
	signal	ac2				: std_logic_vector(15 downto 0);
	signal	i					: std_logic;		-- indirect bit
	
		
BEGIN
	
	PROCESS (clk, nRESET)
	BEGIN
		if nRESET = '0' then
			i  <= '0';
			ar <= "000000000000";
			pc <= "000100000000";
			dr <= "0000000000000000";
			ac <= "0000000000000000";
			ir <= "0000000000000000";
			tr <= "0000000000000000";


		elsif falling_edge(clk) then		-- register instance
			if ar_ld ='1' then
				if instStepMode = '1' then
					if instStop = '0' then
						ar <= cb_node(11 downto 0);
					else
						ar <= ar;
					end if;
				else
				ar <= cb(11 downto 0);
				end if;
			elsif ar_inr = '1' then
				ar <= ar + "000000000001";	
			elsif ar_clr = '1' then
				ar <= "000000000000";
			end if;

	-------------------------------------------------------------------		
			if pc_ld = '1' then
					pc <= cb(11 downto 0);	
			elsif pc_inr = '1' then
				if instStepMode = '1' then
					if instStop = '0' then
						pc <= pc + "000000000001";
					else
						pc <= pc;
					end if;
				else
					pc <= pc + "000000000001";
				end if;
			elsif pc_clr = '1' then
				pc <= "000000000000";
			end if;

	---------------------------------------------------------------------			
			if dr_ld = '1' then
					dr <= cb;
			elsif dr_inr = '1' then
					dr <= dr + "0000000000000001";
			end if;
   ------------------------------------------------------------------------
			if ac_ld = '1' then
				ac <= ac_in;
			elsif ac_inr = '1' then
				if instStepMode = '1' then
					if instStop = '0' then
						ac <= ac + "0000000000000001";
					else
						ac <= ac;
					end if;
				else
					ac <= ac + "0000000000000001";
				end if;
			elsif ac_clr = '1' then
				ac <= "0000000000000000";
			end if;
-----------------------------------------------------------------------------------
			if ir_ld = '1' then
				ir <= cb(15 downto 0);
			end if;
-------------------------------------------------------------------------------			
			if tr_ld = '1' then
				tr <= cb(15 downto 0);
			end if;
--------------------------------------------------------------------------------------			
			if ir(15) = '1' then
				i <= '1';
			else
				i <= '0';	
			end if;
-------------------------------------------------------------------------------------------
		end if;
END PROCESS;
	
	

	process(nRESET, clk0, ar)
	begin
		if nRESET = '0' then
			address <= "000000000000";
		elsif rising_edge(clk0) then
			address <= ar;
		end if;
	end process;
	
	PROCESS (clk, nRESET)
	BEGIN
		if nRESET = '0' then
			ac2 <= "0000000000000000";
		elsif rising_edge(clk) then		-- register instance
			if ac_ld ='1' or ac_inr = '1' or ac_clr = '1' then
				ac2 <= ac;
			end if;
		end if;
	end process;

	
	PROCESS(ar, x, cb, cb_node, pc, dr, ac, ir, tr)
	BEGIN
		case x is
			when "0000001" =>				-- AR output
				cb_node(15 downto 12) <= "0000";
				cb_node(11 downto 0) <= ar;
				cb <= cb_node;
			when "0000010" =>				-- PC output
				cb_node(11 downto 0) <= pc;
				cb_node(15 downto 12) <= "0000";
				cb <= cb_node;
			when "0000100" =>				-- DR output
				cb_node <= dr;
				cb <= cb_node;
			when "0001000" =>				-- AC output
				cb_node <= ac;
				cb <= cb_node;
			when "0010000" =>				-- IR output
				cb_node <= ir;
				cb <= cb_node;
			when "0100000" =>				-- TR output
				cb_node <= tr;
				cb <= cb_node;
			when "1000000" =>				-- Memory input
				cb <= "ZZZZZZZZZZZZZZZZ";
				cb_node <= cb;
			when others =>				
				cb <= "ZZZZZZZZZZZZZZZZ";
				cb_node <= "0000000000000000";
			end case;
	end process;
	
	ir_dec_out <= ir(14 downto 12);
	ar_out <= ar;
	ac_out <= ac2;
	dr_out <= dr;
	I_out <= i;
	--cb_out <= cb_node;
	ir_out <= ir(15 downto 0);
	pc_out <= pc;
	ac_value <= ac;
	tr_out <= tr;
	
END regs_arch;