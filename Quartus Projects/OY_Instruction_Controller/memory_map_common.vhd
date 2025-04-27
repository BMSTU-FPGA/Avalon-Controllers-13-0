library ieee; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package memory_map_common is
	procedure analyze_byteenable(signal byteenable : in std_logic_vector(3 downto 0);
								 signal internal_readdata : in std_logic_vector(31 downto 0);
								 signal readdata : out std_logic_vector(31 downto 0));
end package;


package body memory_map_common is
    procedure analyze_byteenable(signal byteenable : in std_logic_vector(3 downto 0);
								 signal internal_readdata : in std_logic_vector(31 downto 0);
								 signal readdata : out std_logic_vector(31 downto 0)) is
	begin
		if (byteenable(0) = '1') then
			readdata(7 downto 0) <= internal_readdata(7 downto 0);
		else
			readdata(7 downto 0) <= (others => '0');
		end if;

		if (byteenable(1) = '1') then
			readdata(15 downto 8) <= internal_readdata(15 downto 8);
		else
			readdata(15 downto 8) <= (others => '0');
		end if;

		if (byteenable(2) = '1') then
			readdata(23 downto 16) <= internal_readdata(23 downto 16);
		else
			readdata(23 downto 16) <= (others => '0');
		end if;

		if (byteenable(3) = '1') then
			readdata(31 downto 24) <= internal_readdata(31 downto 24);
		else
			readdata(31 downto 24) <= (others => '0');
		end if;
	end procedure analyze_byteenable;
end memory_map_common;