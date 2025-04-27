library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.memory_map_common.all;

entity TEST_OY_Controller is
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
end entity TEST_OY_Controller;

architecture rtl_2 of TEST_OY_Controller is

  component TEST_OY is
    generic (
      n    : integer;
      mode : integer;
      cu   : integer);
    port (
      clk           : in std_logic;
      reset         : in std_logic;
      sko           : buffer std_logic;
      sno           : buffer std_logic;
      okay          : out std_logic;
      defect        : out std_logic;
      finish        : buffer std_logic;
      real_rez      : buffer std_logic_vector(n * 2 - 1 downto 0);
      true_rez      : buffer std_logic_vector(n * 2 - 1 downto 0);
      x             : buffer std_logic_vector(n - 1 downto 0);
      y             : buffer std_logic_vector(n - 1 downto 0);
      start_pattern : in std_logic_vector(2 * n - 1 downto 0);
      stop_pattern  : in std_logic_vector(2 * n - 1 downto 0)
    );
  end component;

  signal internal_readdata       : std_logic_vector(31 downto 0);
  signal internal_start_pattern  : std_logic_vector(2 * n - 1 downto 0);
  signal internal_stop_pattern   : std_logic_vector(2 * n - 1 downto 0);
  signal internal_defect_pattern : std_logic_vector(2 * n - 1 downto 0);
  signal internal_a              : std_logic_vector(n - 1 downto 0);
  signal internal_b              : std_logic_vector(n - 1 downto 0);
  signal internal_finish         : std_logic;
  signal internal_defect         : std_logic;
  signal internal_start          : std_logic;

  signal interupt_enable_on_finish : std_logic;
  signal interupt_enable_on_defect : std_logic;
begin
  process (csi_clk, rsi_reset)
  begin

    -- Reset signals
    if (rsi_reset = '1') then
      internal_start         <= '1';
      internal_start_pattern <= (others => '0');
      internal_stop_pattern  <= (others => '1');
      ins_irq                <= '0';
    elsif (rising_edge(csi_clk)) then

      -- Clearing signals on the next clock cycle
      if (internal_start = '1') then
        internal_start <= '0';
      end if;

      -- Writing
      if (avs_chipselect = '1' and avs_write = '1') then

        -- 1st word
        if (avs_address = "00") then
          -- Setting start pattern
          if (avs_byteenable(0) = '1') then
            internal_start_pattern <= avs_writedata;
          end if;

          -- 2nd word
        elsif (avs_address = "01") then
          -- Setting stop pattern
          if (avs_byteenable(0) = '1') then
            internal_stop_pattern <= avs_writedata;
          end if;

          -- 4th word
        elsif (avs_address = "11") then
          --setting control register
          if (avs_byteenable(0) = '1') then
            ins_irq                   <= avs_writedata(0);
            interupt_enable_on_finish <= avs_writedata(2);
            interupt_enable_on_defect <= avs_writedata(4);
            internal_start            <= avs_writedata(5);
          end if;
        end if;
      end if;

      -- Setting ins_irq signal
      if (internal_finish = '1') then
        ins_irq <= interupt_enable_on_finish or ins_irq;
      elsif (internal_defect = '1') then
        ins_irq <= interupt_enable_on_defect or ins_irq;
      end if;

    end if;
  end process;

  process (avs_chipselect, avs_read, avs_byteenable, internal_readdata)
  begin
    -- Reading
    if (avs_chipselect = '1' and avs_read = '1') then
      analyze_byteenable(avs_byteenable, internal_readdata, avs_readdata);
    end if;
  end process;
  avs_waitrequest <= '0' when interupt_enable_on_defect = '1' else
    '0' when interupt_enable_on_finish = '1' else
    '0' when avs_read = '1' else
    '0' when avs_write = '1' else
    '0' when internal_finish = '1' else
    '0' when internal_defect = '1' else
    '1';
  -- Reading
  with avs_address select internal_readdata <=
    internal_start_pattern when "00", -- 1st word
    internal_stop_pattern when "01", -- 2nd word
    internal_a & internal_b when "10", -- 3rd word
    "00000000000000000000000000" & internal_start & interupt_enable_on_defect & internal_defect
    & interupt_enable_on_finish & internal_finish & ins_irq when "11"; -- 4th word

  TEST_OY_Instance : TEST_OY
  generic map(n, mode => 4, cu => 0)
  port map
  (
    clk           => csi_clk,
    reset         => internal_start,
    x             => internal_a,
    y             => internal_b,
    defect        => internal_defect,
    finish        => internal_finish,
    start_pattern => internal_start_pattern,
    stop_pattern  => internal_stop_pattern
  );

end architecture rtl_2;