library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
library work;
 
 
entity Decomp_Mili is
	port
   (
		x1, x2, clk, ena, clrn: in std_logic;
		y1, y2, y3, tau1, tau2: buffer std_logic
   );
end Decomp_Mili;

 
architecture Struct of Decomp_Mili is
	component ks1_voz_mili
		Port
		( 
			t2: in std_logic;
			x1, x2: in std_logic;
			J, K, D: out std_logic
		);
	end component;
	
	component memory_JKD
		Port
		( 
			J, K, D: in std_logic;
			t1, t2: buffer std_logic;
			clk, ena, clrn: in std_logic
		);
	end component;
	
	component ks2_out_mili
		Port
		( 
			t1, t2: in std_logic;
			x1, x2: in std_logic;
			y1, y2, y3: out std_logic
		);
	end component;
	
	signal J, K, D: std_logic;

begin

	Memmory_Excitation : ks1_voz_mili
	port map(tau2, x1, x2, J, K, D);
	 

	Memmory : memory_JKD
	port map(J, K, D, tau1, tau2, clk, ena, clrn);
	
	Output : ks2_out_mili
	port map(tau1, tau2, x1, x2, y1, y2, y3);

end Struct;