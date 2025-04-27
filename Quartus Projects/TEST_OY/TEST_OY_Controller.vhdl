library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.memory_map_common.all;

entity TEST_OY_Controller is
  generic (
    n    : integer := 16;
    mode : integer := 4;
    cu   : integer := 0);
  port (
    avs_chipselect  : in std_logic;
    avs_address     : in std_logic_vector(1 downto 0);
    avs_read        : in std_logic;
    avs_readdata    : out std_logic_vector(31 downto 0);
    avs_write       : in std_logic;
    avs_writedata   : in std_logic_vector(31 downto 0);
    avs_byteenable  : in std_logic_vector(3 downto 0);
    avs_waitrequest : out std_logic;
    csi_clk         : in std_logic;
    rsi_reset       : in std_logic;
    ins_irq         : buffer std_logic
  );
end entity;
architecture rtl of TEST_OY_Controller is
  component CONTROLLED_TEST_OY
    generic (
      n    : integer := 16;
      mode : integer := 4;
      cu   : integer := 0);
    port (
      clk    : in std_logic; -- тактовый сигнал, внешний для стенда
      reset  : in std_logic; -- сигнал начальной установки, внешний для стенда
      sko    : buffer std_logic; -- сигнал конца операции, формируется испытуемым устройством
      sno    : buffer std_logic; -- сигнал начала операции, формируется в стенде после снятия reset и каждый раз после sko
      okay   : out std_logic; -- сигнал формируется модулем analise в случае совпадения результата с эталоном
      defect : out std_logic; -- сигнал обнаружения несовпадения результата с эталоном
      finish : buffer std_logic; -- сигнал, свидетельствующий о формировании последнего тестового набора

      start_patern : in std_logic_vector(n * 2 - 1 downto 0);
      stop_patern  : in std_logic_vector(n * 2 - 1 downto 0);

      real_rez : buffer std_logic_vector(n * 2 - 1 downto 0); -- результат с испытуемого устройства
      true_rez : buffer std_logic_vector(n * 2 - 1 downto 0); -- правильный результат

      x : buffer std_logic_vector(n - 1 downto 0); -- первый операнд (множимое)
      y : buffer std_logic_vector(n - 1 downto 0) -- второй операнд (множитель)
    );
  end component;

  signal internal_readdata     : std_logic_vector(31 downto 0);
  signal internal_reset        : std_logic;
  signal internal_clock        : std_logic;
  signal internal_clock_manual : std_logic;
  signal internal_x            : std_logic_vector(n - 1 downto 0);
  signal internal_y            : std_logic_vector(n - 1 downto 0);
  signal internal_c            : std_logic_vector(2 * n - 1 downto 0);
  signal internal_sno          : std_logic;
  signal internal_sko          : std_logic;

  signal internal_eiof   : std_logic;
  signal internal_start  : std_logic;
  signal internal_eiod   : std_logic;
  signal internal_fof    : std_logic;
  signal internal_irq    : std_logic;
  signal internal_defect : std_logic;

  signal internal_okay     : std_logic;
  signal internal_real_rez : std_logic_vector(n * 2 - 1 downto 0);
  signal internal_true_rez : std_logic_vector(n * 2 - 1 downto 0);

  signal internal_start_pattern_register  : std_logic_vector(2 * n - 1 downto 0);
  signal internal_end_pattern_register    : std_logic_vector(2 * n - 1 downto 0);
  signal internal_defect_pattern_register : std_logic_vector(2 * n - 1 downto 0);
  signal mode_switch                      : std_logic; -- 0: auto, 1: manual
  signal interupt_enable                  : std_logic;
  signal read_wait                        : std_logic;
begin

  process (csi_clk, rsi_reset)
  begin

    -- Reset signals
    if (rsi_reset = '1') then
      internal_reset <= '1';
      internal_x     <= (others => '0');
      internal_y     <= (others => '0');
      ins_irq        <= '0';
    elsif (rising_edge(csi_clk)) then

      -- Clearing signals on the next clock cycle
      if (internal_reset = '1') then
        internal_reset <= '0';
      end if;
      if (internal_sno = '1') then
        internal_sno <= '0';
      end if;
      if (internal_clock_manual = '1') then
        internal_clock_manual <= '0';
      end if;

      -- Writing
      if (avs_chipselect = '1' and avs_write = '1') then
        -- 1st word
        if (avs_address = "00") then
          -- Setting CR
          if (avs_byteenable(0) = '1') then
            internal_eiof   <= avs_writedata(0);
            internal_start  <= avs_writedata(1);
            internal_eiod   <= avs_writedata(2);
            internal_fof    <= avs_writedata(3);
            internal_irq    <= avs_writedata(8);
            internal_defect <= avs_writedata(9);
          end if;

          -- 2nd word
        elsif (avs_address = "01") then
          -- Setting StartPattern
          if (avs_byteenable(0) = '1') then
            internal_start_pattern_register <= avs_writedata(2 * n - 1 downto 0);
            internal_sno                    <= '1';
            internal_clock_manual           <= '1';
          end if;
          -- 3rd word
        elsif (avs_address = "10") then
          -- Setting EndPattern
          if (avs_byteenable(0) = '1') then
            internal_end_pattern_register <= avs_writedata(2 * n - 1 downto 0);
            internal_sno                  <= '1';
            internal_clock_manual         <= '1';
          end if;

          -- 4th word
        elsif (avs_address = "11") then
          -- Relate to write to DefectPattern
          if (avs_byteenable(0) = '1') then
            internal_sno          <= '1';
            internal_clock_manual <= '1';
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

  process (avs_chipselect, avs_read, avs_byteenable, internal_readdata)
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
    "000000000000000000000" & internal_defect & internal_irq & "0000" & internal_fof & internal_eiod & internal_start & internal_eiof when "00", -- 4th word
    internal_start_pattern_register when "01", -- 1st word
    internal_end_pattern_register when "10", -- 2nd word
    internal_defect_pattern_register when "11"; -- 3rd word

  internal_clock <= (not mode_switch and csi_clk) or (mode_switch and internal_clock_manual);

  CONTROLLED_TEST_OY_inst : CONTROLLED_TEST_OY
  generic map(
    n    => n,
    mode => mode,
    cu   => cu
  )
  port map
  (
    clk          => internal_clock,
    reset        => internal_reset,
    sko          => internal_sko,
    sno          => internal_sno,
    okay         => internal_okay,
    defect       => internal_defect,
    finish       => internal_fof,
    start_patern => internal_start_pattern_register,
    stop_patern  => internal_end_pattern_register,
    real_rez     => internal_real_rez,
    true_rez     => internal_true_rez,
    x            => internal_x,
    y            => internal_y
  );

end architecture;
