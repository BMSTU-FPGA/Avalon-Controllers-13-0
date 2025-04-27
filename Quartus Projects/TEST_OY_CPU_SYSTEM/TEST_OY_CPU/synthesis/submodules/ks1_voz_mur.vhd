library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ks1_voz_mur is
Port
( 
	t1, t2, t3: in std_logic;
	x1, x2: in std_logic;
	J, K, D, T: out std_logic
);
end ks1_voz_mur;


architecture arch of ks1_voz_mur is
begin
	J <= t2;
	K <= (x1 nor x2) nor ((x1 nor x1) nor (x2 nor x2));
	D <= not((x2 nor x2) or ((x1 nor x1) nor t2) or ((x1 nor x1) nor (t1 nor t1)));
	T <= not(not(x2 or (t1 nor t1) or (t2 nor t2)) or not((x1 nor x1) or x2 or (t3 nor t3)) or not((x2 nor x2) or (t1 nor t1) or (t3 nor t3)) or not((x2 nor x2) or t1 or t3));
end arch;

