LIBRARY ieee;
USE ieee.std_logic_1164.all; 
LIBRARY work;
configuration Operation_Device of CONTROLLED_TEST_OY is
for bdf_type
	for uut : OperationDevice
		use entity OperationDeviceMine(MealyDevice);	--Вот здесь подключать своё ОУ
		end for;
end for;
end Operation_Device;