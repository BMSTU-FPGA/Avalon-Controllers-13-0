library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
library work;
 
 
entity Decomp_Mur is
	port
   (
		x1, x2, clk, ena, clrn: in std_logic;
		y1, y2, y3, tau1, tau2, tau3: buffer std_logic
   );
end Decomp_Mur;

 
architecture Struct of Decomp_Mur is
	component ks1_voz_mur
		Port
		( 
			t1, t2, t3: in std_logic;
			x1, x2: in std_logic;
			J, K, D, T: out std_logic
		);
	end component;
	
	component memory_JKDT
		Port
		( 
			J, K, D, T: in std_logic;
			t1, t2, t3: buffer std_logic;
			clk, ena, clrn: in std_logic
		);
	end component;
	
	component ks2_out_mur
		Port
		( 
			t1, t2, t3: in std_logic;
			x1, x2: in std_logic;
			y1, y2, y3: out std_logic
		);
	end component;
	
	signal J, K, D, T: std_logic;

begin

	Memmory_Excitation : ks1_voz_mur
	port map(tau1, tau2, tau3, x1, x2, J, K, D, T);
	 

	Memmory : memory_JKDT
	port map(J, K, D, T, tau1, tau2, tau3, clk, ena, clrn);
	
	Output : ks2_out_mur
	port map(tau1, tau2, tau3, x1, x2, y1, y2, y3);

end Struct;