library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Operation_automat is
	generic (n: integer:=4);
	port
	(
		y: in std_logic_vector(8 downto 0);
		x: out std_logic_vector(2 downto 0);
		a: in std_logic_vector(n-1 downto 0);
		b: in std_logic_vector(n-1 downto 0);
		c: buffer std_logic_vector(n*2-1 downto 0);
		clk : in std_logic;
		internal_a : out std_logic_vector(2*n-1 downto 0);
		internal_b : out std_logic_vector(n-1 downto 0)
	);
end Operation_automat;


architecture Operation_automat_arch of Operation_automat is
	signal T: std_logic_vector(n*2-1 downto 0);
	signal rb: std_logic_vector(n-1 downto 0);
	signal rc: std_logic_vector(n*2-1 downto 0);
	signal counter: integer range 0 to n;
begin

	execution: process(clk)
	begin
		if clk'event and clk='1' then
			if (y(0)='1') then c <= (others => '0'); rb <= b; end if;
			if (y(1)='1') then T(n*2-1 downto n) <= (others => a(n-1)); T(n-1 downto 0) <= a; end if;
			if (y(2)='1') then counter <= n-1; end if;
			if (y(3)='1') then c <= c + T; end if;
			if (y(4)='1') then c <= c + 0; end if;
			if (y(5)='1') then T <= T(n*2-2 downto 0) & '0'; end if;
			if (y(6)='1') then counter <= counter - 1; end if;
			if (y(7)='1') then rb <= rb(n-1) & rb(n-1 downto 1); end if;
			if (y(8)='1') then c <= c + not(T) + 1; end if;
		end if;
	end process;
	
	x(0) <= rb(0);
	x(1) <= '1' when counter=0 else '0';
	x(2) <= rb(n-1);

	internal_a <= T(2*n-1 downto 0);
	internal_b <= rb;

end Operation_automat_arch;