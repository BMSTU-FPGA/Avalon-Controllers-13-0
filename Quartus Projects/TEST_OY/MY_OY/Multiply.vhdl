library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Multiply is
	generic (n:integer:=4);
	port (
		x: in std_logic_vector(0 to n-1);
		y: in std_logic_vector(0 to n-1);
		z: out std_logic_vector(0 to 2*n-2)
	);
end Multiply;

architecture Behavioral of Multiply is

begin
	process (x, y)
		variable rx: std_logic_vector(0 to n-1);
		variable ry: std_logic_vector(0 to n-1);
		variable rz: std_logic_vector(0 to 2*n-2);
		variable i: integer;
begin
		rx := x;
		ry := y;
		rz := (others => '0');
		i := 1;
		for i in 1 to n-1 loop
			if (ry(n-1)='1') then
				rz(0 to n-1) := rz(0 to n-1) + rx;
			end if;
			rz := rz(0) & rz(0 to 2*n - 3);
			ry := '0' & ry(0 to n - 2);
		end loop;
		if (ry(n-1) = '1') then
			rz(0 to n-1) := rz(0 to n-1) + not(rx) + 1;
		end if;
		z <= rz;
	end process;
end architecture;