-- Instruction decoder
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY control IS
	PORT(	t			: in	std_logic_vector(15 downto 0);
			M_t		: in	std_logic_vector(15 downto 0);
			i			: in 	std_logic;
			e			: in	std_logic;
			fgi, fgo	: in	std_logic;
			d			: in 	std_logic_vector(7 downto 0);
			ac			: in	std_logic_vector(15 downto 0);
			dr			: in	std_logic_vector(15 downto 0);
			ir			: in	std_logic_vector(15 downto 0);
			int_r		: in	std_logic;
			clk2		: in 	std_logic;
			instStepMode, instStop	: in	std_logic;
		
			decode		: out	std_logic;
			sc_clr_out	: out	std_logic;
			sc_stop		: out	std_logic;
			tr_ld			: out	std_logic;
			ar_ld, ar_inr, ar_clr	: out	std_logic;
			pc_ld, pc_inr, pc_clr	: out	std_logic;
			dr_ld, dr_inr				: out	std_logic;
			ac_ld, ac_inr, ac_clr	: out	std_logic;
			ir_ld							: out	std_logic;
		
			e_clr, e_cme				: out	std_logic;
			inp_rd, out_ld				: out	std_logic;

			x									: out	std_logic_vector(7 downto 1);
			M_read, M_write, M_enable	: out	std_logic;
			c_and, c_add, c_dr			: out	std_logic;
			c_inpr, c_com, c_shr			: out	std_logic;
			c_shl, c_inr		 			: out	std_logic;
	
			ien_set					: out 	std_logic;
			ien_clr					: out 	std_logic);
END control;

ARCHITECTURE design of control IS

	signal	dr_val, ac_val					: std_logic;
	signal	rd, wr							: std_logic;
	signal 	M_read_node, M_write_node	: std_logic;
	signal	p_buf, r_buf					: std_logic;
	signal	sc_clr							: std_logic;
	signal	int_s_clr						: std_logic;
	
BEGIN

	process(dr)	
	begin
		if (conv_integer(dr) = 0) then
			dr_val <= '0';
		else
			dr_val <= '1';
		end if;	
	end process;

	process(ac)	
	begin
		if (conv_integer(ac) = 0) then
			ac_val <= '0';
		else
			ac_val <= '1';
		end if;
	end process;

	process(d(7), i, t(3), ir(0))	
	begin
		sc_stop <= d(7) and not i and t(3) and ir(0);	-- register reference HLT
	end process;

	process(d(7), i, t(3),int_r, p_buf, ir, dr_val, r_buf, ac, ac_val, e, fgi, fgo, sc_clr, instStepMode, instStop, int_s_clr)
	begin 
			p_buf <= d(7) and i and t(3);
			r_buf <= d(7) and (not i) and t(3);
		
			ien_clr <= (int_r and t(2)) or (p_buf and ir(6));
			ien_set <= (p_buf and ir(7));
			
			e_clr <= r_buf and ir(10);				-- register CLE
			e_cme <= r_buf and ir(8); 				-- register CME
	
			decode <= not int_R and t(2);	-- Decode
			--i_ld_ir15 <= not int_R and t(2);	-- Decode
			
			pc_ld <= (d(4) and t(4)) or (d(5) and t(5));
			tr_ld <= int_R and t(0);

			ar_ld <= (not int_R and t(2)) 
					or (not int_R and t(0))
					or ((not int_R) and t(2))		-- Decode 
					or ((not d(7)) and i and t(3));		-- indirect
					
			ar_clr <= int_R and t(0);			-- interrupt cycle
			ar_inr <= (d(5) and t(4));			-- memory BSA
			
			ir_ld <= (not int_R) and t(1);	-- Fetch 
				
			pc_inr <= ((not int_R) and t(1)) 		-- Fetch 
				or (int_R and t(2)) 				-- interrupt cycle
				or (((not dr_val) and d(6) and t(6))) 	-- memory ISZ
				or (r_buf and ir(4) and (not ac(15)))	-- register SPA
				or (r_buf and ir(3) and ac(15))			-- register SNA
				or (r_buf and ir(2) and (not ac_val))	-- register SZA
				or (r_buf and ir(1) and (not e))		-- register SZE
				or (p_buf and ir(9) and fgi)			-- SKI(Skip if Input flag is set)
				or (p_buf and ir(8) and fgo);			-- SKO(Skip if Output flag is set) 
					
			pc_clr <= int_R and t(1);			-- interrupt cycle
			
			dr_ld <= (d(0) and t(4)) 			-- memory AND
				or (d(1) and t(4)) 				-- memory ADD
				or (d(2) and t(4))				-- memory LDA
				or (d(6) and t(4));				-- memory ISZ
				
			dr_inr <= (d(6) and t(5));			-- memory ISZ
			
			ac_ld <= (d(2) and t(5))		-- memory LDA
				or (d(0) and t(5))			-- memory AND 
				or (d(1) and t(5)) 				-- memory ADD
				or (r_buf and ir(9)) 			-- register CMA
				or (r_buf and ir(7)) 			-- register CIR
				or (r_buf and ir(6))			-- register CIL
				or (p_buf and ir(11));			-- I/O INP
				
				
			ac_clr <= (r_buf and ir(11));		-- register CLA	

			ac_inr <= (r_buf and ir(5));				-- register INC
			
			
			inp_rd <= (p_buf and ir(11));			-- I/O INP
			
			out_ld <= (p_buf and ir(10));			-- I/O OUT
			--outr_ld <= (p_buf and ir(10));
			
			x(1) <= (d(4) and t(4))				-- memory BUN, PC <- AR
				or (d(5) and t(5));  			-- memory BSA, PC <- AR
				
			x(2) <= (not int_R and t(0))		-- Fetch, AR <- PC
				or (int_R and t(0))				-- interrupt cycle, TR <- PC
				or (d(5) and t(4));				-- memory BSA, M[AR] <- PC
				
			x(3) <= (d(2) and t(5))				-- memory LDA, AC <- DR
				or (d(6) and t(6));				-- memory ISZ, M[AR] <- DR
				
			x(4) <= (d(3) and t(4))				-- memory STA, M[AR] <- AC
						or (p_buf and ir(10));			-- I/O OUT, OUTR <- AC(0-7)
				
			x(5) <= (not int_R and t(2));		-- decode, D0-D7 <- Decode IR(12-14),
												-- AR <- IR(0-11), I <- IR(15)
			
			x(6) <= (int_R and t(1));			-- interrupt cycle, M[AR] <- TR
			
			x(7) <= (not int_R and t(1))		-- Fetch, IR <- M[AR]
				or (not d(7) and i and t(3))	-- indirect, AR <- M[AR]
				or (d(0) and t(4))				-- memory AND, DR <- M[AR]
				or (d(1) and t(4))				-- memory ADD, DR <- M[AR]
				or (d(2) and t(4))				-- memory LDA, DR <- M[AR]
				or (d(6) and t(4));				-- memory ISZ, DR <- M[AR]		

			c_and <= d(0) and t(5);				-- AND micro operation
			c_add <= d(1) and t(5);				-- ADD
			c_dr <= d(2) and t(5);				-- LDR
			c_inpr <= p_buf and ir(11);			-- INP
			c_com <= r_buf and ir(9);			-- CMA
			c_shr <= r_buf and ir(7);			-- SHR
			c_shl <= r_buf and ir(6);			-- SHL
			c_inr <= r_buf and ir(5);			-- INC

			if instStepMode = '1' then
				if instStop = '0' then
					int_s_clr <= int_R and t(2);
				else
					int_s_clr <= '1';
				end if;
			else
					int_s_clr <= int_R and t(2);
			end if;	
			
			sc_clr <= p_buf				-- I/O reference instruction
				  or r_buf 					-- register reference instruction
				  or int_s_clr				-- interrupt cycle	  
				  or (d(0) and t(5)) 	-- memory AND
				  or (d(1) and t(5)) 	-- memory ADD
				  or (d(2) and t(5))		-- memory LDA
				  or (d(3) and t(4)) 	-- memory STA
				  or (d(4) and t(4)) 	-- memory BUN
				  or (d(5) and t(5))		-- memory BSA
				  or (d(6) and t(6)) 	-- memory ISZ
				  or (r_buf and t(2));
			sc_clr_out <= sc_clr;
			--p <= p_buf;
	end process;		

	
	process(M_t, int_R, d, i, clk2)
	begin
		M_write <= (int_R and M_t(1) and clk2)						-- interrupt cycle
						or (d(3) and M_t(4) and clk2) 				-- memory STA
						or (d(5) and M_t(4) and clk2) 				-- memory BSA
						or (d(6) and M_t(6) and clk2);				-- memory ISZ
						
		M_enable <= (M_t(1) and clk2)									-- interrupt cycle
						or (d(3) and M_t(4) and clk2) 				-- memory STA
						or (d(5) and M_t(4)and clk2) 				-- memory BSA
						or (d(6) and M_t(6) and clk2)				-- memory ISZ
						or (not d(7) and i and M_t(3) and clk2)		-- decode
						or (d(0) and M_t(4) and clk2)				-- memory AND
						or (d(1) and M_t(4) and clk2)				-- memory ADD
						or (d(2) and M_t(4) and clk2)				-- memory LDA
						or (d(6) and M_t(4) and clk2);				-- memory ISZ
	
		M_read <= (not int_R and M_t(1) and clk2)					-- Fetch cycle
						or (not d(7) and i and M_t(3) and clk2)		-- decode
						or (d(0) and M_t(4) and clk2)				-- memory AND
						or (d(1) and M_t(4) and clk2)				-- memory ADD
						or (d(2) and M_t(4) and clk2)				-- memory LDA
						or (d(6) and M_t(4) and clk2);				-- memory ISZ
	end process;
	
END design;