	component TEST_OY_CPU is
		port (
			clk_clk : in std_logic := 'X'  -- clk
		);
	end component TEST_OY_CPU;

	u0 : component TEST_OY_CPU
		port map (
			clk_clk => CONNECTED_TO_clk_clk  -- clk.clk
		);

