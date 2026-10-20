	component HelloNiosPIO is
		port (
			clk_clk     : in  std_logic                    := 'X';             -- clk
			leds_export : out std_logic_vector(9 downto 0);                    -- export
			sw_export   : in  std_logic_vector(9 downto 0) := (others => 'X')  -- export
		);
	end component HelloNiosPIO;

	u0 : component HelloNiosPIO
		port map (
			clk_clk     => CONNECTED_TO_clk_clk,     --  clk.clk
			leds_export => CONNECTED_TO_leds_export, -- leds.export
			sw_export   => CONNECTED_TO_sw_export    --   sw.export
		);

