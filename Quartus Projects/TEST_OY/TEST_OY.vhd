-- В этом файле содержится проект стенда TEST_OY для тестирования операционных устройств, созданных студентами по части 
-- выполнения операции умножения.
-- Если испытуемое OY может выполнять не только операцию умножения, то в entity OY следует добавить входной порт cop и присвоить ему начальное значение
-- соответствующее операции умножения.
-- В папке MY_OY содержатся файлы проекта испытуемого устройства - это один из студенческих проектов 

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
-- 	приводится кодирование параметра mode 
--		он задает формат представления исходных операндов
--		0   Прямой код, целые числа.
--		1   Прямой код, дробные числа.
--		2   Обратный код, целые числа.
--		3   Обратный код, дробные числа.
--		4   Дополнительный код, целые числа.
--		5   Дополнительный код, дробные числа.

--		Параметр cu задаёт тип управляющего автомата
--		0   Автомат МИЛИ
--		1   Автомат МУРА

ENTITY TEST_OY IS 
GENERIC (n : INTEGER:=4; mode : integer:=4; cu : integer:=0);
	PORT
	(
		clk :  IN  STD_LOGIC;						-- тактовый сигнал, внешний для стенда
		reset :  IN  STD_LOGIC;						-- сигнал начальной установки, внешний для стенда
		sko :  buffer  STD_LOGIC;					-- сигнал конца операции, формируется испытуемым устройством
		sno :  buffer  STD_LOGIC;					-- сигнал начала операции, формируется в стенде после снятия reset и каждый раз после sko
		okay :  OUT  STD_LOGIC;						-- сигнал формируется модулем analise в случае совпадения результата с эталоном
		defect :  OUT  STD_LOGIC;					-- сигнал обнаружения несовпадения результата с эталоном
		finish :  buffer  STD_LOGIC;				-- сигнал, свидетельствующий о формировании последнего тестового набора
		real_rez :  buffer  STD_LOGIC_VECTOR(n*2-1 DOWNTO 0);	-- результат с испытуемого устройства
		true_rez :  buffer  STD_LOGIC_VECTOR(n*2-1 DOWNTO 0);	-- правильный результат
		x :  buffer  STD_LOGIC_VECTOR(n-1 DOWNTO 0);				-- первый операнд (множимое)
		y :  buffer  STD_LOGIC_VECTOR(n-1 DOWNTO 0)				-- второй операнд (множитель)
	);
END TEST_OY;

ARCHITECTURE bdf_type OF TEST_OY IS 

-- В архитектурное тело входит испытуемое операционное устройство - это компонент Operation_device 
COMPONENT Operation_device
GENERIC (n : INTEGER);									-- параметр, задает разрядность операндов
	PORT(clk : IN STD_LOGIC;							-- тактовый сигнал, внешний для стенда
		 set : IN STD_LOGIC;								-- сигнал начальной установки
		 sno : IN STD_LOGIC;								-- сигнал начала операции
		 a : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);	-- первый операнд (множимое)
		 b : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);	-- второй операнд (множитель)
		 sko : OUT STD_LOGIC;							-- сигнал конца операции
		 rc : OUT STD_LOGIC_VECTOR(n*2-1 DOWNTO 0)-- результат (произведение)
	);
END COMPONENT;

BEGIN
	gen_test:
	process (clk)				-- этот процесс формирует тестовые наборы для проверки испытуемого ОУ
		constant start_patern:STD_LOGIC_VECTOR(2*n-1 downto 0):=(others =>'0');	-- первый тестовый набор
		constant	stop_patern:STD_LOGIC_VECTOR(2*n-1 downto 0):=(others =>'1');	-- последний тестовый набор
		variable   cnt		   : std_logic_vector (2*n-1 downto 0);

	begin
		if (rising_edge(clk)) then
			if reset = '1' then		
				cnt := start_patern;				-- установка счетчика в начальное состояние	
			elsif sko = '1' and cnt/=stop_patern then			   
				cnt := cnt + 1;					-- инкремент счетчика
			end if;
		end if;
		-- Output the current count
		if cnt=stop_patern then finish <= '1';		-- если сформирован последний тестовый набор, устанавливается сигнал finish
			else finish <= '0';
		end if;
		x <= cnt(2*n-1  downto n);				-- используем в качестве первого операнда (множимого) 
		y <= cnt(n-1 downto 0);					-- используем в качестве второго операнда (множителя)
	end process;
	
	ctl_unit: 
	process (clk,reset) 							-- этот процесс формирует сигнал sno 
	variable v_sno : std_logic;				-- переменная для sno
	begin
		if (reset = '1') then				
			v_sno :='1';
		elsif (rising_edge(clk)) then 		-- по восходящему фронту 
			if(sko='1'and finish='0') then	-- если есть sko и это не последний тестовый набор, то
				v_sno :='1';						-- формируем sno
			else v_sno :='0';						-- иначе нет
			end if;
		end if;
		if ((cu=1 and falling_edge(clk)) or cu=0) then
			sno<=v_sno; 
		end if;
	 end process;

	analise_unit: 
	process(reset,clk)							-- этот процесс сравнивает результат, формируемый испытуемым устройством с эталонным результатом
	variable noll:STD_LOGIC_VECTOR(n*2-1 DOWNTO 0);
	begin
		noll:=(others=>'0');
		if (reset = '1') then
			okay<='1'; defect<='0';				-- вначале 			
		elsif (rising_edge(clk)) then
			if(sko='1') then
				if(mode=2 or mode=3) then			--если обратный код
					if((x(n-1)xor y(n-1))/=real_rez(2*n-1) and (real_rez=noll or real_rez=not noll)) then	--если нужна коррекция при +0 или -0
						if((real_rez)=not true_rez) then
							okay<='1';						-- если результат совпадает not(true_rez)
						end if;
						if((real_rez)/=not true_rez) then
							okay<='0'; defect<='1';		-- если результат не совпадает not(true_rez)
						end if;
					else						--если не нужна коррекция при +0 или -0
						if(real_rez=true_rez) then
							okay<='1';			-- если результат совпадает с эталоном
						else
							okay<='0'; defect<='1';		-- если результат не совпадает с эталоном
						end if;
					end if;
				else						--если не обратный код
					if(real_rez=true_rez) then
						okay<='1';			-- если результат совпадает с эталоном
					else
						okay<='0'; defect<='1';		-- если результат не совпадает с эталоном
					end if;
				end if;
			end if;
		end if;
	end process;

	actual_result:
	process(x,y)	-- этот процесс формирует эталонный результат умножения, для заданных операндов 
		variable mbin : std_logic_vector(2*n-1 downto 0);	-- для вычисления произведения
		variable xbin,ybin,xp,yp : std_logic_vector(n-1  downto 0);
		variable nol : std_logic_vector(2*n-1 downto 0);
	-- хр,ур преобразованные множимое и множитель
	begin
		xbin:=x;		-- множимое
		ybin:=y;		-- множитель
		if xbin(n-1)='1' then 
			if(mode=0 or mode=1) then	-- если множимое отрицательное, то преобразум его в положительное
				xp:='0'& xbin(n-2 downto 0);	--  если прямой код
			elsif(mode=2 or mode=3) then xp:=not xbin(n-1 downto 0);		--  если обратный код
			elsif(mode=4 or mode=5) then xp:=not xbin(n-1 downto 0)+1;		--  если дополнительный код
			end if;
			else xp:=xbin; 
		end if;												-- иначе, не меняем множимое
		if ybin(n-1)='1' then -- аналогичным образом преобразум множитель, если он отрицательный
			if(mode=0 or mode=1) then yp:='0'& ybin(n-2 downto 0);		-- если прямой код
			elsif(mode=2 or mode=3) then yp:=not ybin(n-1 downto 0);	-- если обратный код
			elsif(mode=4 or mode=5) then yp:=not ybin(n-1 downto 0)+1;	-- если дополнительный код
			end if;
			else yp:=ybin; end if;										-- иначе, не меняем множитель
		mbin:=xp*yp;			-- вычисляем произведение для положительных операндов
		if (ybin(n-1) xor xbin(n-1))='1' then		-- если результат отрицательный, представляем его в заданном коде
			if(mode=0) then mbin(2*n-1):='1'; -- в знаковый разряд записываем '1', если прямой код и целые числа
			elsif(mode=1) then mbin:='1'& mbin(2*n-3 downto 0)&'0';						-- если прямой код и дробные числа
			elsif(mode=2) then mbin:=not mbin;-- mbin(2*n-1):='1';						-- если обратный код и целые числа
			elsif(mode=3) then mbin:=not mbin; mbin:='1'& mbin(2*n-3 downto 0)&'1';		-- если обратный код и дробные числа 									   
			elsif(mode=4) then if mbin/=0 then 											-- если дополнительный код и целые числа
				mbin:=not mbin+1; mbin(2*n-1):='1'; end if;
			elsif(mode=5) then if mbin/=0 then											-- если дополнительный код и дробные числа
				mbin:=not mbin+1; mbin:='1'& mbin(2*n-3 downto 0)&'0'; end if;
									   end if;
		else				-- если результат положительный
				  if(mode=0 or mode=2 or mode=4) then null;-- если числа целые
				  elsif(mode=1 or mode=3) then mbin(2*n-2 downto 0):=mbin(2*n-3 downto 0)&'0'; -- если числа дробные в прямом или обратном коде
				  elsif(mode=5) then mbin(2*n-1 downto 0):=mbin(2*n-2 downto 0)&'0'; -- если числа дробные в дополнительном коде
				end if;
		end if;
		true_rez <= mbin;	--передаем на выход действительный результат
	end process;

	uut: 	 Operation_device				-- это экземпляр испытуемого устройства с именем uut
	GENERIC MAP(n => n)					-- его разрядность
	PORT MAP(clk => clk,					-- тактовый сигнал
			 set => reset,					-- установка в начальное состояние
			 sno =>sno,						-- сигнал начала операции, формируется в стенде после снятия reset и каждый раз после sko
			 a => x,							-- первый операнд (множимое)
			 b => y,							-- второй операнд (множитель)						
			 sko => sko,					-- сигнал конца операции, формируется испытуемым устройством
			 rc =>real_rez);				-- результат с испытуемого устройства
END bdf_type;