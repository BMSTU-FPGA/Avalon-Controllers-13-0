library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ks2_out_mur is
Port
( 
	t1, t2, t3: in std_logic;
	x1, x2: in std_logic;
	y1, y2, y3: out std_logic
);
end ks2_out_mur;


architecture arch of ks2_out_mur is
begin
	y1 <= (t1 nor t3) nor ((t1 nor t1) nor t2);
	y2 <= (t1 nor t1) nor ((t2 nor t2) nor (t2 nor t2));
	y3 <= not(not((t1 nor t1) or t2 or t3) or (t1 nor (t2 nor t2)) or (t1 nor (t3 nor t3)));
end arch;

