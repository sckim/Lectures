	component HelloNios is
		port (
			clk_clk : in std_logic := 'X'  -- clk
		);
	end component HelloNios;

	u0 : component HelloNios
		port map (
			clk_clk => CONNECTED_TO_clk_clk  -- clk.clk
		);

