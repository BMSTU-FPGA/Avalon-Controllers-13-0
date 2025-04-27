library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity OperationDeviceMine is
  generic (
    n : integer
  );
  port (
    clk, set, sno : in std_logic;
    a, b          : in std_logic_vector(0 to n - 1);

    sko : out std_logic;
    rc  : out std_logic_vector(0 to 2 * n - 1)
  );
end entity;

architecture MealyDevice of OperationDeviceMine is
  component Dev_OperationAutomata is
    port (
      clk : in std_logic;

      y    : in std_logic_vector(0 to 9);
      x    : out std_logic_vector(0 to 1);
      a, b : in std_logic_vector(0 to n - 1);
      c    : buffer std_logic_vector(0 to 2 * n - 1)
    );
  end component;

  component Dev_ControlUnit is
    port (
      clk, set, sno : in std_logic;
      y             : out std_logic_vector(0 to 9);
      x             : in std_logic_vector(0 to 1);

      sko : out std_logic
    );
  end component;

  signal s_x : std_logic_vector(0 to 1);
  signal s_y : std_logic_vector(0 to 9);
begin
  OA : entity work.OperationAutomata
    generic map(
      n => n
    )
    port map
    (
      y   => s_y,
      x   => s_x,
      a   => a,
      b   => b,
      rc  => rc,
      clk => clk
    );

  CU : entity work.ControlUnit(arch_mealy)
    port map
    (
      y   => s_y,
      x   => s_x,
      clk => clk,
      set => set,
      sno => sno,
      sko => sko
    );
end architecture MealyDevice;
