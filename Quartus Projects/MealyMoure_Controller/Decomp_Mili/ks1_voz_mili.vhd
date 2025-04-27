library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ks1_voz_mili is
Port
( 
	t2: in std_logic;
	x1, x2: in std_logic;
	J, K, D: out std_logic
);
end ks1_voz_mili;


architecture arch of ks1_voz_mili is
begin
	J <= t2;
	K <= (x1 nor x2) nor ((x1 nor x1) nor (t2 nor t2));
	D <= ((x1 nor x1) nor t2) nor not(x1 or x2 or (t2 nor t2));
end arch;

