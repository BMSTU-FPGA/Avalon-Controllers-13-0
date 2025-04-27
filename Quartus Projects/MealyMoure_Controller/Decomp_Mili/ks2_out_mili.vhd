library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ks2_out_mili is
Port
( 
	t1, t2: in std_logic;
	x1, x2: in std_logic;
	y1, y2, y3: out std_logic
);
end ks2_out_mili;


architecture arch of ks2_out_mili is
begin
	y1 <= not((x1 nor x2) or not((x1 nor x1) or (x2 nor x2) or (t1 nor t1)) or not((x1 nor x1) or x2 or (t2 nor t2)) or not((x2 nor x2) or t1 or t2));
	y2 <= not((x1 nor (x2 nor x2)) or ((x2 nor x2) nor t1) or ((x1 nor x1) nor t2));
	y3 <= not(not(x1 or (t1 nor t1) or (t2 nor t2)) or not(x1 or (x2 nor x2) or t2) or not((x1 nor x1) or x2 or t2));
end arch;

