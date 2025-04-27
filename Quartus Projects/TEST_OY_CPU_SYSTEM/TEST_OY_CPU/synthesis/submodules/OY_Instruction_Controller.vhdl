library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity OY_Instruction_Controller is
    generic (
        n: integer := 16
    );
    port (
        ncs_clk, ncs_reset, ncs_start : in std_logic;
        ncs_dataa, ncs_datab          : in std_logic_vector(0 to 31);

        ncs_done			: out std_logic;
        ncs_result      : out std_logic_vector(0 to 31)
    );
end entity OY_Instruction_Controller;

architecture MealyDevice of OY_Instruction_Controller is
    component Dev_OperationAutomata is
        port (
            clk   : in std_logic;
            
            y:    in     std_logic_vector(0 to 9);
            x:    out    std_logic_vector(0 to 1);
            a, b: in     std_logic_vector(0 to n - 1);
            c:    buffer std_logic_vector(0 to 2 * n - 1)
        );
    end component;

    component Dec_ControlUnit is
        port (
            clk, set, sno: in std_logic;
            y:    out   std_logic_vector(0 to 9);
            x:    in    std_logic_vector(0 to 1);
            
            sko:  out   std_logic
        );
    end component;

    signal s_x:      std_logic_vector(0 to 1);
    signal s_y:      std_logic_vector(0 to 9);
	 signal internal_a: std_logic_vector(0 to n - 1);
	 signal internal_b: std_logic_vector(0 to n - 1);
begin
	 internal_a <= ncs_dataa(n to 2*n - 1);
	 internal_b <= ncs_datab(n to 2*n - 1);
	
    OA: entity work.OperationAutomata
     generic map(
        n => n
    )
     port map(
        y => s_y,
        x => s_x,
        a => internal_a,
        b => internal_b,
        rc => ncs_result,
        clk => ncs_clk
    );

    CU: entity work.ControlUnit(arch_mealy)
     port map(
        y => s_y,
        x => s_x,
        clk => ncs_clk,
        set => ncs_reset,
        sno => ncs_start,
        sko => ncs_done
    );
end architecture MealyDevice;
