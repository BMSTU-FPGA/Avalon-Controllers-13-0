-- В этом файле содержится описание управляющего автомата ControlUnit из методички
-- Архитектурное тело arch_mealy описывает поведение автомата МИЛИ
-- УА формирует необходимую последовательность
-- управляющих сигналов y в зависимости от значений логических условий x

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Далее следует описание интерфейса УА
entity ControlUnit is
Port
		( y: out std_logic_vector(8 downto 0); 		--управляющие сигналы
	   x: in std_logic_vector(2 downto 0);  			--логические условия  
	   clk: in std_logic;  									--синхросигнал                             
		set: in std_logic; 									--сигнал начальной установки
		sno: in std_logic; 									--сигнал начала операции
		sko:out std_logic 									--сигнал конца операции
		);
end ControlUnit;
-- Далее следует описание архитектурного тела УА в виде автомата МИЛИ 
architecture arch_mealy of ControlUnit is
type T_state is(s0,s1,s2);							-- используем перечислимый тип для состояний УА
signal state,Next_state:T_state;					-- текущее состояние УА, следующее состояние УА
   begin
NS:process(state,sno,x) --этот процесс формирует следующее состояние УА, управляющие силгналы y и сигнал конца операции SKO
	begin
	sko<='0';					-- нет sko
	y<="000000000";			-- nmk
 case state is
		when s0 => 
			if (sno='1') 											--если есть сигнал SNO
			then Next_state<=s1; y<="000001111";			-- => s1 mk1
			else Next_state<=s0; y<="000000000";			-- => s0 nmk
			end if;
		when s1 =>
			if ((x(0) ='1')and (x(1)='1')) 					-- знаковый разряд равен 1
			then Next_state <=s2;y<="000010000";			-- => s2 mk2 	
			elsif ((x(0)='1') and (x(1)='0')) 				-- цифровой разряд равен единице
			then Next_state<=s2;y<="000100000";				-- => s2 mk3
			elsif((x(0)='0')and(x(2)='0')) 					-- анализ.разряд равен нулю и это не последний разряд
			then Next_state <=s1;y<="111000000";			-- => s1 mk4 
			else Next_state<=s0;y<="000000000";sko<='1';	-- =>s0 nmk sko
			end if;
		when s2 =>
			if(x(2)='1') 											-- если последний разряд
			then Next_state <=s0; y<="000000000";sko<='1';--=> s0 nmk sko 
			else Next_state <=s1; y<="111000000";			-- =>s1 mk4, если не последний
			end if;
	end case;
	end process NS;
	--формирование текущего состояния
 state <=s0 when set ='1' else --если есть сигнал начальной установки
  Next_state when clk'event and clk='1' --по положительному фронту clk
  else state;
  end arch_mealy;
 