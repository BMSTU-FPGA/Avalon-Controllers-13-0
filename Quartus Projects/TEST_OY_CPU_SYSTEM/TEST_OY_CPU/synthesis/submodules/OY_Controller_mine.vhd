library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.memory_map_common.all;



entity OY_Controller is
	generic (n: integer:=16);
   port (
	   avs_chipselect  : in std_logic;
		avs_address     : in  std_logic_vector(1 downto 0);
		avs_read        : in  std_logic;
		avs_readdata    : out std_logic_vector(31 downto 0);
      avs_write       : in  std_logic;
      avs_writedata   : in  std_logic_vector(31 downto 0);
		avs_byteenable  : in  std_logic_vector(3 downto 0);
		avs_waitrequest : out std_logic;
      csi_clk   		 : in  std_logic;
      rsi_reset 		 : in  std_logic;
		ins_irq	 		 : buffer std_logic
    );
end entity OY_Controller;



architecture rtl_2 of OY_Controller is
	component OY
		generic (n: integer);
		port
		(
			a: in std_logic_vector(n-1 downto 0);
			b: in std_logic_vector(n-1 downto 0);
			c: out std_logic_vector(2*n-1 downto 0);
			sno: in std_logic;
			sko: out std_logic;
			clk: in std_logic;
			set: in std_logic;
			internal_a : out std_logic_vector(n-1 downto 0);
			internal_b : out std_logic_vector(n-1 downto 0)
		);
	end component;

	signal internal_readdata : std_logic_vector(31 downto 0);
	signal internal_reset : std_logic;
	signal internal_clock : std_logic;
	signal internal_clock_manual : std_logic;
	signal internal_a : std_logic_vector(n-1 downto 0);
	signal internal_b : std_logic_vector(n-1 downto 0);
	signal oy_int_a : std_logic_vector(n-1 downto 0);
	signal oy_int_b : std_logic_vector(n-1 downto 0);
	signal internal_c : std_logic_vector(2*n-1 downto 0);
	signal internal_sno : std_logic;
	signal internal_sko : std_logic;
	
	signal mode_switch : std_logic; -- 0: auto, 1: manual
	signal interupt_enable : std_logic;
	signal read_wait : std_logic;
begin

	 
	 process (csi_clk, rsi_reset)
	 begin
		
		-- Reset signals
		if (rsi_reset = '1') then
			internal_reset <= '1';
			internal_a <= (others => '0');
			internal_b <= (others => '0');
			ins_irq <= '0';
			
		
		elsif (rising_edge(csi_clk)) then

			-- Clearing signals on the next clock cycle
			if (internal_reset = '1') then internal_reset <= '0'; end if;
			if (internal_sno = '1') then internal_sno <= '0'; end if;
			if (internal_clock_manual = '1') then internal_clock_manual <= '0'; end if;
			
			-- Writing
			if (avs_chipselect = '1' and avs_write = '1') then
				-- 1st word
				if (avs_address = "00") then
					-- Setting RA
					if (avs_byteenable(0) = '1') then
						internal_a <= avs_writedata(n-1 downto 0);
					end if;
				
				-- 2nd word
				elsif (avs_address = "01") then
					-- Setting RB
					if (avs_byteenable(0) = '1') then
						internal_b <= avs_writedata(n-1 downto 0);
						internal_sno <= '1';
						internal_clock_manual <= '1';
					end if;

				-- 4th word
				elsif (avs_address = "11") then
					if (avs_byteenable(0) = '1') then
						internal_reset <= avs_writedata(0);
						mode_switch <= avs_writedata(1);
						interupt_enable <= avs_writedata(2);
						ins_irq <= avs_writedata(3);
						
						-- internal_reset
						if (avs_writedata(0) = '1') then
							internal_a <= (others => '0');
							internal_b <= (others => '0');
						end if;
					end if;
				end if;
			end if;

			-- Reading in manual mode
			if (avs_chipselect = '1' and avs_read = '1' and avs_address = "10" and mode_switch = '1') then
				internal_clock_manual <= '1';
			end if;
	
			-- Setting ins_irq signal
			if (internal_sko = '1') then
				ins_irq <= interupt_enable or ins_irq;
			end if;
		
		end if;
	 end process;

	 process(avs_chipselect, avs_read, avs_byteenable, internal_readdata)
	 begin
		-- Reading
		if (avs_chipselect = '1' and avs_read = '1') then
			-- read_wait <= '1';
			analyze_byteenable(avs_byteenable, internal_readdata, avs_readdata);
		end if;
	 end process;


	 avs_waitrequest <= '0' when interupt_enable = '1' else
	 						  '0' when avs_read = '1' else
	 						  '0' when avs_write = '1' else
							  '0' when internal_sko = '1' else
							  '0' when mode_switch = '1' else
							  '1';

	 -- Reading
	 with avs_address select internal_readdata <=
	 	 "0000000000000000" & oy_int_a when "00", -- 1st word
		 "0000000000000000" & oy_int_b when "01", -- 2nd word
	    internal_c when "10", -- 3rd word
		 "000000000000000000000000000" & internal_sko & ins_irq & interupt_enable & mode_switch & '0' when "11"; -- 4th word

	 internal_clock <= (not mode_switch and csi_clk) or (mode_switch and internal_clock_manual);


	 OY_inst: entity work.OperationDevice
	  generic map(
		 n => n
	 )
	  port map(
		 clk => internal_clock,
		 set => internal_reset,
		 sno => internal_sno,
		 a => internal_a,
		 b => internal_b,
		 sko => internal_sko,
		 rc => internal_c,
		 internal_a => oy_int_a,
		 internal_b => oy_int_b
	 );

end architecture rtl_2; -- of OY_Controller