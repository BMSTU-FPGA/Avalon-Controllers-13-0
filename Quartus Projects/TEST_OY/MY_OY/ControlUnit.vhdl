library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--- Описание интерфейса УА
entity ControlUnit is
    port
    (
        y:   out  std_logic_vector(0 to 8); --- Коды операций 
        x:   in   std_logic_vector(0 to 1); --- Коды условий
        clk: in   std_logic;                --- Тактовый сигнал
        set: in   std_logic;                --- Разрешающий сигнал
        sno: in   std_logic;                --- Сигнал начала операции
        sko: out  std_logic                 --- Сигнал конца операции
    );
end ControlUnit;

--- Описание архитектуры УА МИЛИ
architecture arch_mealy of ControlUnit is
    type T_state is (s0, s1, s2, s3); --- Алфавит состояний
    signal state, next_state : T_state;
    begin
        NS: process(state, sno, x)
        begin
            sko<='0';
            y<="0000000000";
        
            case state is
                when s0 =>
                    if (sno = '1') then
                        --- Устанавливаем операнды в изначальное положение 
                        next_state <= s1; 
                        y <= "1111000000";
                    else
                        --- Ожидание разрешающего сигнала
                        next_state <= s0;
                        y <= "0000000000";
                    end if;
                
                when s1 =>
                    if (x(0) = '0') then
                        if (x(1) = '1') then
                            --- Прибавляем множимое
                            y <= "0000100000";
                        end if;
                        next_state <= s2;
                    else 
                        if (x(1) = '1') then
                            --- Делаем корректирующий шаг
                            y <= "0000010000";
                        end if;
                        next_state <= s3;
                    end if;
                
                when s2 =>
                    --- Осуществляем сдвиг операндов
                    y <= "0000001110";
                    next_state <= s1;
                
                when s3 =>
                    --- Отправляем сигнал конца операции
						  y <= "0000000001";
                    sko <= '1';
                    next_state <= s0;
                
                when others =>
                    null;
            end case;
    end process NS;
        
    state <= s0         when set = '1' else              --- Ждем подачи сигнала
             next_state when rising_edge(clk) else       --- Переход в следущее состояние по положительному фронту clk
             state;

end architecture arch_mealy;



