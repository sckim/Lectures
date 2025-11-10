-- Instruction decoder
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY inputoutput IS
	PORT(	nRESET				: in	std_logic;
			clk					: in	std_logic;
			clk2					: IN	std_logic;-- 1 purse per 0.01 for 7-segment 
			clk20000				: in	std_logic;
			inp_rd, out_ld		: in 	std_logic;
			ien_set, ien_clr	: in	std_logic;
			t						: in	std_logic_vector(15 downto 0);
			fgo_sw				: in	std_logic;
		
--		key input from '0' to 'F'
			keyIn					: in	std_logic_vector(15 downto 0);
		
-- 	input from common bus
			cb						: in 	std_logic_vector(15 downto 0);	
			instStepMode, instStop	: in	std_logic;
			clk100hz 			: in std_logic;
		
--		input value from INPR to AC
			input_out	: out	std_logic_vector(7 downto 0);
			output_out	: out	std_logic_vector(7 downto 0);
			ien_out		: out	std_logic;
			r_out			: out	std_logic;
		
--		7-segment output from 'a' to 'g'
			fgi_out, fgo_out 					: out	std_logic;
			FNDSEL1_OUT, FNDSEL2_OUT		: OUT std_logic; --output register select signal
			oupt_out1 							: out std_logic_vector(7 downto 0)); -- output 7-segment		
END inputoutput;

ARCHITECTURE design of inputoutput IS

	TYPE STATE_TYPE IS (s0, s1);
	signal	state_fgo				: STATE_TYPE;
	signal	fgi						: std_logic := '0';
	signal	fgo						: std_logic := '0';
	signal	ien						: std_logic;
	signal	r, r2						: std_logic;
	signal	input						: std_logic_vector(7 downto 0);
	signal	output					: std_logic_vector(7 downto 0);
	signal	fgo_set					: std_logic;
	signal	fgo_clk					: std_logic;
	signal	keyIn_node				: std_logic_vector(15 downto 0) := "1111111111111111";
	signal	keyIn_clk				: std_logic_vector(15 downto 0);
	signal	key_clk					: std_logic;
--	signal   FNDSEL1, FNDSEL2		: std_logic;						-- the locations of the output 7-segment
	signal   segOut1					: std_logic_vector(7 downto 0); -- temporary store for output 7-segment
	signal	segOut2					: std_logic_vector(7 downto 0); -- temporary store for output 7-segment
	
BEGIN

-- to debounce the input key chattering
	process(nRESET, clk20000)
	begin
		if nRESET = '0' then
			keyIn_node(15 downto 0) <= "0000000000000000";
		elsif rising_edge(clk20000) then
			keyIn_node(15 downto 0) <= keyIn(15 downto 0);
		end if;
	end process;

	key_clk <= 	keyIn_node(0) or keyIn_node(1) or keyIn_node(2) or keyIn_node(3) or			
				keyIn_node(4) or keyIn_node(5) or keyIn_node(6) or keyIn_node(7) or
				keyIn_node(8) or keyIn_node(9) or keyIn_node(10) or keyIn_node(11) or
				keyIn_node(12) or keyIn_node(13) or keyIn_node(14) or keyIn_node(15);
	--keyClk <= key_clk;			
					
-- process for input register and flag
	PROCESS (clk, nRESET, key_clk, keyIn_node, fgi, inp_rd)
	BEGIN
		if nRESET = '0' then
			input <= "00000000";
			fgi <= '0';
		elsif inp_rd = '1' then
			fgi <= '0';
		elsif rising_edge(key_clk) then
			case keyIn(15 downto 0) is 
				when "0000000000000001" => input <= "00000000"; fgi <= '1';
				when "0000000000000010" => input <= "00000001"; fgi <= '1';
				when "0000000000000100" => input <= "00000010"; fgi <= '1';
				when "0000000000001000" => input <= "00000011"; fgi <= '1';
				when "0000000000010000" => input <= "00000100"; fgi <= '1';
				when "0000000000100000" => input <= "00000101"; fgi <= '1';
				when "0000000001000000" => input <= "00000110"; fgi <= '1';
				when "0000000010000000" => input <= "00000111"; fgi <= '1';
				when "0000000100000000" => input <= "00001000"; fgi <= '1';
				when "0000001000000000" => input <= "00001001"; fgi <= '1';
				when "0000010000000000" => input <= "00001010"; fgi <= '1';
				when "0000100000000000" => input <= "00001011"; fgi <= '1';
				when "0001000000000000" => input <= "00001100"; fgi <= '1';
				when "0010000000000000" => input <= "00001101"; fgi <= '1';
				when "0100000000000000" => input <= "00001110"; fgi <= '1';
				when "1000000000000000" => input <= "00001111"; fgi <= '1';
				when others => null;
			end case;
		end if;
	end process;

	process(nRESET, clk20000, fgo_sw)
	begin
		if nRESET = '0' then
			fgo_set <= '0';
		elsif rising_edge(clk20000) then
			fgo_set <= fgo_sw;
		end if;
	end process;
	
-- generating fgo clock with duration of clk
	process(nRESET, clk, fgo_set)
	begin
		if nRESET = '0' then
			state_fgo <= s0;
			fgo_clk <= '1';
		elsif rising_edge(clk) then
			case state_fgo is 
				when s0 => 
					if fgo_set = '1' then
						state_fgo <= s0;
						fgo_clk <= '1';
					elsif fgo_set = '0' then
						state_fgo <= s1;
						fgo_clk <= '0';
					end if;
				when s1 =>
					if fgo_set = '1' then
						state_fgo <= s0;
						fgo_clk <= '1';
					elsif fgo_set = '0' then
						state_fgo <= s1;
						fgo_clk <= '1';
					end if;
			end case;
		end if;
	end process;
--	fgo_clk_out <= fgo_clk;
	
-- process for output register and flag
	PROCESS (clk, nRESET, fgo, fgo_clk, out_ld, output)
		variable	k			: std_logic_vector(1 downto 0);
	BEGIN
--		k := out_ld & fgo & fgo_set;
		k := out_ld & fgo_clk;
		
		if nRESET = '0' then
			output <= "00000000";
			fgo <= '1';

		elsif falling_edge(clk) then
			if out_ld = '1' and fgo = '1' then
				output <= cb(7 downto 0);
			end if;
				case k is
					when "00" => fgo <= '1';	-- fgo switch is pressed
					when "01" => fgo <= NULL;	-- nothing happend
					when "10" => fgo <= NULL;	-- out_ld is enabled and fgo switch is pressed   
					when "11" => fgo <= '0';	-- out_ld is enabled
					when others => NULL;
			end case;
		end if;
		
-- 7-segment decoder from OUTR
		case output(7 downto 4) is
--										     "abcdefg-"
			when "0000"	=> segOut1 <= "11111100"; 
			when "0001"	=> segOut1 <= "01100000"; 
			when "0010"	=> segOut1 <= "11011010"; 
			when "0011"	=> segOut1 <= "11110010"; 
			when "0100"	=> segOut1 <= "01100110"; 
			when "0101"	=> segOut1 <= "10110110"; 
			when "0110"	=> segOut1 <= "10111110"; 
			when "0111"	=> segOut1 <= "11100000"; 
			when "1000"	=> segOut1 <= "11111110"; 
			when "1001"	=> segOut1 <= "11100110"; 
			when "1010"	=> segOut1 <= "11111010"; 
			when "1011"	=> segOut1 <= "00111110"; 
			when "1100"	=> segOut1 <= "00011010"; 
			when "1101"	=> segOut1 <= "01111010"; 
			when "1110"	=> segOut1 <= "11011110"; 
			when "1111"	=> segOut1 <= "10001110"; 
			when others => segOut1 <= "ZZZZZZZZ"; 
		end case;
		case output(3 downto 0) is
--											  "abcdefg-"
			when "0000"	=> segOut2 <= "11111100"; 
			when "0001"	=> segOut2 <= "01100000"; 
			when "0010"	=> segOut2 <= "11011010"; 
			when "0011"	=> segOut2 <= "11110010"; 
			when "0100"	=> segOut2 <= "01100110"; 
			when "0101"	=> segOut2 <= "10110110"; 
			when "0110"	=> segOut2 <= "10111110"; 
			when "0111"	=> segOut2 <= "11100000"; 
			when "1000"	=> segOut2 <= "11111110"; 
			when "1001"	=> segOut2 <= "11100110"; 
			when "1010"	=> segOut2 <= "11111010"; 
			when "1011"	=> segOut2 <= "00111110"; 
			when "1100"	=> segOut2 <= "00011010"; 
			when "1101"	=> segOut2 <= "01111010"; 
			when "1110"	=> segOut2 <= "11011110"; 
			when "1111"	=> segOut2 <= "10001110"; 
			when others => segOut2 <= "ZZZZZZZZ"; 
		end case;	
	end process;	
	
-- OUTPUT FORWARD SEGMENT AND BACKWARD SEGMENT
--	Process(clk100Hz, segOut1, segOut2, FNDSEL1, FNDSEL2)
	Process(clk100Hz, segOut1, segOut2)
	Begin
		if(clk100Hz = '0') then
			FNDSEL1_OUT <= '1';
			FNDSEL2_OUT <= '0';
			oupt_out1 <= segOut1(7 downto 0);
		else
			FNDSEL1_OUT <= '0';
			FNDSEL2_OUT <= '1';
			oupt_out1 <= segOut2(7 downto 0);
		end if;
--		FNDSEL1_OUT <= FNDSEL1;
--		FNDSEL2_OUT <= FNDSEL2;
	end process;
	
	
-- process for ien flip-flop		
	PROCESS (clk2, nRESET, ien_set, ien_clr)
	BEGIN
		if nRESET = '0' then
			ien <= '0';
		elsif falling_edge(clk2) then
			if ien_set = '1' then
				ien <= '1';
			elsif ien_clr = '1' then
				ien <= '0';
			end if;
		end if;
	end process;
	
	-- process for interrupt flip-flop(R flip-flop)
	process(clk2, nRESET, t, ien, fgi, fgo)
	begin
		if nRESET = '0' then
			r <= '0';
		elsif falling_edge(clk2) then
			if instStepMode = '1' then
				if instStop = '0' then
					if (not t(0) and not t(1) and not t(2) and ien and (fgi or fgo)) = '1' then
						r <= '1';
					end if;
				else
					r <= r;
				end if;
			else
				if (not t(0) and not t(1) and not t(2) and ien and (fgi or fgo)) = '1' then
					r <= '1';
				end if;
			end if;	
			if (r and t(2)) = '1' then
				r <= '0';
			end if;
		end if;
	end process;
	
	-- process for r2 : a copy of r
	process(clk2, nRESET)
	begin
		if nRESET = '0' then
			r2 <= '0';
		elsif rising_edge(clk2) then
			r2 <= r;
		end if;
	end process;

	input_out <= input;
	output_out <= output;
	fgi_out <= fgi;
	fgo_out <= fgo;
	ien_out <= ien;
	r_out <= r2;
END design;	
