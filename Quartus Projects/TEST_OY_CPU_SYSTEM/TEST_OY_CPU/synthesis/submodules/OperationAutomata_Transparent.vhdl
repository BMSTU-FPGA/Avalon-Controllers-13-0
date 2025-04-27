-- В этом файле содержится описание операционного автомата
-- ОА выполняет микрооперации, каждая из которых задается своим управляющим сигналом у
-- и формирует логические условия х

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OperationAutomata_Transparent is
    generic(n:integer:=4);  -- параметр n определяет разрядность операндов
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
end OperationAutomata_Transparent;

architecture arch of OperationAutomata_Transparent is
    signal ra: std_logic_vector(0 to n); --регистр множимого
    signal rb: std_logic_vector(0 to n-1); --регистр множителя
    signal i:  integer range 1 to n;       --счетчик анализируемого разряда 
    begin 
        process(clk) -- этот процесс описывает выполняемые в ОА микрооперации
        begin
            if (clk'event and clk='1') then -- по положительному фронту clk
                if (y(0)='1') then ra <= a(0) & a;                                    -- прием в ra множимого 
                end if;
                if (y(1)='1') then rb <= b;                                    -- прием в rb множителя
                end if;
                if (y(2)='1') then rc <= (others =>'0');                       -- обнуление rc
                end if;
                if (y(3)='1') then i <= 1;                                     -- инициализация i
                end if;
                if (y(4)='1') then rc(0 to n) <= rc(0 to n) + ra;          -- прибавляем множимое
                end if;
                if (y(5)='1') then rc(0 to n) <= rc(0 to n) + not(ra) + 1; -- корректирующий шаг -[A]д
                end if;
                if (y(6)='1') then rc <= rc(0) & rc(0 to 2*n-2);               -- сдвиг вправо rc
                end if; 
                if (y(7)='1') then rb <= '0' & rb(0 to n-2);                   -- сдвиг вправо rb
                end if;
                if (y(8)='1') then i <= i + 1;                                 -- инкремент i
                end if;
                if (y(9)='1') then rc <= rc(1 to 2*n-1) & '0';
                end if;
            end if;
    end process;
    
    -- Формируемые ОА логические условия
    x(0) <= '1' when i>=n         else '0';    -- анализируемый разряд множителя
    x(1) <= '1' when rb(n-1)='1'  else '0';    -- признак анализа знакового разряда

    internal_a <= ra(1 to n);
    internal_b <= rb;

end architecture arch;
