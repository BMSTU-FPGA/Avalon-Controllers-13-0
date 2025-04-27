library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
library work;
 
 
entity OY is
	generic (n: integer:=4);
	port
   (
		a: in std_logic_vector(n-1 downto 0);
		b: in std_logic_vector(n-1 downto 0);
		c: out std_logic_vector(n*2-1 downto 0);
		sno: in std_logic;
		sko: out std_logic;
		clk: in std_logic;
		set: in std_logic;
		internal_a : out std_logic_vector(2*n-1 downto 0);
		internal_b : out std_logic_vector(n-1 downto 0)
   );
end OY;

 
architecture Struct of OY is
	component Operation_automat
		generic (n: integer);
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
	end component;
	
	component Control_automat
		port
		(
			y: out std_logic_vector(8 downto 0);
			x: in std_logic_vector(2 downto 0);
			clk: in std_logic;
			set: in std_logic;
			sno: in std_logic;
			sko: out std_logic
		);
	end component;
	 
	signal y_signals: std_logic_vector(8 downto 0);
	signal x_signals: std_logic_vector(2 downto 0);
begin

	Operation_Unit : Operation_automat
	generic map(n)
	port map(y_signals, x_signals, a, b, c, clk, internal_a, internal_b);
	 

	Control_Unit : Control_automat
	port map(y_signals, x_signals, clk, set, sno, sko);

end Struct;