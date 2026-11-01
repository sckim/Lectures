	component HelloNiosIntr is
		port (
			clk_clk     : in  std_logic                    := 'X'; -- clk
			leds_export : out std_logic_vector(9 downto 0)         -- export
		);
	end component HelloNiosIntr;

	u0 : component HelloNiosIntr
		port map (
			clk_clk     => CONNECTED_TO_clk_clk,     --  clk.clk
			leds_export => CONNECTED_TO_leds_export  -- leds.export
		);

