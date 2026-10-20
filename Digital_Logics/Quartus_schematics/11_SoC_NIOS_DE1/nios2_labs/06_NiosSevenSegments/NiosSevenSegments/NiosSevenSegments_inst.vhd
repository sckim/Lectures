	component NiosSevenSegments is
		port (
			clk_clk          : in  std_logic                     := 'X'; -- clk
			hex3_hex0_export : out std_logic_vector(31 downto 0);        -- export
			hex5_hex4_export : out std_logic_vector(15 downto 0)         -- export
		);
	end component NiosSevenSegments;

	u0 : component NiosSevenSegments
		port map (
			clk_clk          => CONNECTED_TO_clk_clk,          --       clk.clk
			hex3_hex0_export => CONNECTED_TO_hex3_hex0_export, -- hex3_hex0.export
			hex5_hex4_export => CONNECTED_TO_hex5_hex4_export  -- hex5_hex4.export
		);

