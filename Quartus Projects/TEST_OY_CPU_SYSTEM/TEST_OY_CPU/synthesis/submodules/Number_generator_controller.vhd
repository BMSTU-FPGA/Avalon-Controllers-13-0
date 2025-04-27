library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Number_generator_controller is
    port (
		  avs_s0_chipselect  : in std_logic;
		  avs_s0_byteenable  : in std_logic_vector(3 downto 0);
        avs_s0_read        : in  std_logic                    ;             --       .read
        avs_s0_readdata    : out std_logic_vector(31 downto 0) ; -- := (others => '0') --       .readdata
        avs_s0_write       : in  std_logic                     ;             --       .write
        avs_s0_writedata   : in  std_logic_vector(31 downto 0)  ; --       .writedata
        csi_clk            : in  std_logic                     ;             --  clock.clk
        rsi_reset        : in  std_logic                                  --  reset.reset		  
    );
end entity Number_generator_controller;

architecture rtl of Number_generator_controller is
	component number_generator_mult
		port (
			C : in std_logic;
			nR : in std_logic;
			Z : out std_logic_vector(9 downto 0)
		);
	end component;
	

	signal NG_nreset : std_logic;
	signal NG_clk : std_logic;
	signal register_A0 : std_logic_vector(9 downto 0);
begin

	 process (csi_clk, rsi_reset)
	 begin
		if (rsi_reset = '1') then
			NG_nreset <= '0';
		
		elsif (rising_edge(csi_clk)) then
			-- Clearing signals on the next clock cycle
			if (NG_nreset = '0') then NG_nreset <= '1';
			elsif (NG_clk = '1') then NG_clk <= '0';
			end if;
    

			
			-- Reading
			if (avs_s0_chipselect = '1' and avs_s0_read = '1' and avs_s0_byteenable(0) = '1') then
				avs_s0_readdata(9 downto 0) <= register_A0;
				NG_clk <= '1';
			
			-- Writing
			elsif (avs_s0_chipselect = '1' and avs_s0_write = '1') then
				NG_nreset <= '0';
			end if;
		end if;
	 end process;
	 
	 ng1: number_generator_mult
	 port map (
		C => NG_clk,
		nR => NG_nreset,
		Z => register_A0
	 );
end architecture rtl; -- of Number_generator_controller