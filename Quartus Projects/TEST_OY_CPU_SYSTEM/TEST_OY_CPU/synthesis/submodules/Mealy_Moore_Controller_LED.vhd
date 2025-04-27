library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.memory_map_common.all;


-- Note: do not use "bit" type for controller's signals (qsys does not see such signals)


entity Mealy_Moore_Controller_LED is
    port (
		  avs_s0_chipselect  : in std_logic;
		  avs_s0_byteenable  : in std_logic_vector(3 downto 0);
        avs_s0_read        : in std_logic;
        avs_s0_readdata    : out std_logic_vector(31 downto 0);
        avs_s0_write       : in std_logic;
        avs_s0_writedata   : in std_logic_vector(31 downto 0);
        csi_clk            : in std_logic;
        reset_n            : in std_logic;
		  
		  LEDG					: out std_logic_vector(8 downto 0);
		  LEDR					: out std_logic_vector(17 downto 0)
    );
end entity Mealy_Moore_Controller_LED;



architecture rtl of Mealy_Moore_Controller_LED is
	component Decomp_Mili 		 -- Автомат МИЛИ
		Port
		(
			x1, x2, clk, ena, clrn: in std_logic;
			y1, y2, y3, tau1, tau2: buffer std_logic
		);
	end component;

	component Decomp_Mur 		 -- Автомат МУРА
		Port
		(
			x1, x2, clk, ena, clrn: in std_logic;
			y1, y2, y3, tau1, tau2, tau3: buffer std_logic
		);
	end component;
	

	signal internal_resetn : std_logic;
	signal internal_enable : std_logic;
	signal internal_X : std_logic_vector(1 downto 0);
	signal internal_readdata : std_logic_vector(31 downto 0);
begin

	 process (csi_clk, reset_n)
	 begin
		if (reset_n = '0') then
			internal_X <= "00";
			internal_resetn <= '0';
			internal_enable <= '0';
		
		elsif (rising_edge(csi_clk)) then
			-- Clearing signals on the next clock cycle
			if (internal_resetn = '0') then internal_resetn <= '1'; end if;
			if (internal_enable = '1') then internal_enable <= '0'; end if;
			
			-- Writing
			if (avs_s0_chipselect = '1' and avs_s0_write = '1' and avs_s0_byteenable(0) = '1') then
				internal_X <= avs_s0_writedata(1 downto 0);
				internal_enable <= avs_s0_writedata(6);
				internal_resetn <= not avs_s0_writedata(7);
			end if;

		end if;
	 end process;


	 process (avs_s0_chipselect, avs_s0_read, avs_s0_byteenable, internal_readdata)
	 begin
		-- Reading
		if (avs_s0_chipselect = '1' and avs_s0_read = '1') then
			analyze_byteenable(avs_s0_byteenable, internal_readdata, avs_s0_readdata);
		end if;
	 end process;
	 
	 
	 mealy: Decomp_Mili
	 port map (
		clk => csi_clk, ena => internal_enable, clrn => internal_resetn,
		x1 => internal_X(1), x2 => internal_X(0),
		y1 => internal_readdata(10), y2 => internal_readdata(9), y3 => internal_readdata(8),
		tau1 => internal_readdata(15), tau2 => internal_readdata(14)
	 );
	 
	 moore: Decomp_Mur
	 port map (
		clk => csi_clk, ena => internal_enable, clrn => internal_resetn,
		x1 => internal_X(1), x2 => internal_X(0),
		y1 => internal_readdata(18), y2 => internal_readdata(17), y3 => internal_readdata(16),
		tau1 => internal_readdata(23), tau2 => internal_readdata(22), tau3 => internal_readdata(21)
	 );
	 
	 internal_readdata(1 downto 0) <= internal_X;

	 

	 
	 LEDG(8 downto 7) <= internal_X;
	 LEDG(5 downto 4) <= internal_readdata(15 downto 14);
	 LEDG(2 downto 0) <= internal_readdata(10 downto 8);
	 LEDG(3) <= '0'; LEDG(6) <= '0';
	 
	 LEDR(9 downto 8) <= internal_X;
	 LEDR(6 downto 4) <= internal_readdata(18 downto 16);
	 LEDR(2 downto 0) <= internal_readdata(23 downto 21);
	 LEDR(3) <= '0'; LEDR(7) <= '0';
	 LEDR(17 downto 10) <= (others => '0');

end architecture rtl; -- of Mealy_Moore_Controller_LED