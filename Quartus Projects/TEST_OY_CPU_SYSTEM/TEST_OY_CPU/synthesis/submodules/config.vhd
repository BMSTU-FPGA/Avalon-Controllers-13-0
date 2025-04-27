LIBRARY ieee;
USE ieee.std_logic_1164.all; 
LIBRARY work;
configuration OperationDevice of CONTROLLED_TEST_OY is
for bdf_type
	for uut : OperationDevice
		use entity work.OperationDeviceMine(MealyDevice);	--Вот здесь подключать своё ОУ
		end for;
end for;
end OperationDevice;