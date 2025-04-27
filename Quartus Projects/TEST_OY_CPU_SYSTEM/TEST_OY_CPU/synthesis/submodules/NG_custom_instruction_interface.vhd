library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CI_NG is
	port(
		ncs_clk: in std_logic;
		
		ncs_reset: in std_logic;
		
		ncs_result: out std_logic_vector(31 downto 0)
	);
	
end CI_NG;

architecture rtl of CI_NG is 
	component number_generator
		port (
			C : in std_logic;
			nR : in std_logic;
			Z : out std_logic_vector(9 downto 0)
		);
	end component;
begin
	unit_ng: number_generator
	port map(
		C=>ncs_clk,
		nR=>not ncs_reset,
		Z=>ncs_result(9 downto 0)
	);
	
	ncs_result(31 downto 10) <= (others=>'0');
	
end rtl;