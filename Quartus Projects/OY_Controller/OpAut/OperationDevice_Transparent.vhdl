library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity OperationDevice_Transparent is
    generic (
        n: integer
    );
    port (
        clk, set, sno : in std_logic;
        a, b          : in std_logic_vector(0 to n - 1);

        sko           : out std_logic;
        rc            : out std_logic_vector(0 to 2 * n - 1);
        internal_a, internal_b          : out std_logic_vector(0 to n - 1)
    );
end entity OperationDevice_Transparent;

architecture MealyDevice of OperationDevice_Transparent is
    component Dev_OperationAutomata_Transparent is
        port (
        y:   in     std_logic_vector(0 to 9);     --управляющие сигналы,задают микрооперации
        x:   out    std_logic_vector(0 to 1);     --логические условия
        a:   in     std_logic_vector(0 to n-1);   --1-ый операнд(множимое)
        b:   in     std_logic_vector(0 to n-1);   --2-ой операнд (множитель)
        rc:  buffer std_logic_vector(0 to 2*n-1); --результат (произведение)
        
        clk: in     std_logic;                     --синхросигнал 
        
        internal_a : out std_logic_vector (0 to n-1);
        internal_b : out std_logic_vector (0 to n-1)
    );
    end component;

    component Dev_ControlUnit is
        port (
            clk, set, sno: in std_logic;
            y:    out   std_logic_vector(0 to 9);
            x:    in    std_logic_vector(0 to 1);
            
            sko:  out   std_logic
        );
    end component;

    signal s_x:      std_logic_vector(0 to 1);
    signal s_y:      std_logic_vector(0 to 9);
begin
    OA: entity work.OperationAutomata_Transparent
     generic map(
        n => n
    )
     port map(
        y => s_y,
        x => s_x,
        a => a,
        b => b,
        rc => rc,
        clk => clk,
        internal_a => internal_a,
        internal_b => internal_b
    );

    CU: entity work.ControlUnit(arch_mealy)
     port map(
        y => s_y,
        x => s_x,
        clk => clk,
        set => set,
        sno => sno,
        sko => sko
    );
end architecture MealyDevice;
