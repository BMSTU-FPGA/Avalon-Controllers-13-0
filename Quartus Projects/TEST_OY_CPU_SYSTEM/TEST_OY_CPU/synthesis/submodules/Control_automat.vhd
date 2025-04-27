library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;


entity Control_automat is
	port (
		y: out std_logic_vector(8 downto 0);
		x: in std_logic_vector(2 downto 0);
		clk: in std_logic;
		set: in std_logic;
		sno: in std_logic;
		sko: out std_logic
	);
end Control_automat;


architecture Mili_arch of Control_automat is
	type mili_states is (s0, s1, s2, s3);
	signal state, Next_state : mili_states;
begin

	Next_s: process(state, sno, x)
	begin
		sko <= '0';
		y <= "000000000";
		
		case state is
			when s0 =>
				if (sno='0')
				then Next_state <= s0; y <= "000000000";
				else Next_state <= s1; y <= "000000111";
				end if;
			when s1 =>
				Next_state <= s2;
				if (x(0)='1')
				then y <= "011101000";
				else y <= "011110000";
				end if;
			when s2 =>
				if (x(1)='0')
					then Next_state <= s1; y <= "000000000";
				elsif (x(1)='1' and x(2)='1')
					then Next_state <= s3; y <= "100000000";
				elsif (x(1)='1' and x(2)='0')
					then Next_state <= s0; y <= "000000000"; sko <= '1';
				end if;
			when s3 =>
				Next_state <= s0; y <= "000000000"; sko <= '1';
		end case;
	end process Next_s;
	
	state <= s0 when set='1' else
	Next_state when clk'event and clk='1'
	else state;

end Mili_arch;


architecture Mur_arch of Control_automat is
	type mur_states is (s0, s1, s2, s3, s4, s5);
	signal state, Next_state : mur_states;
begin

	Next_s: process(state, sno, x)
	begin
		Next_state <= s0;
		
		case state is
			when s0 =>
				if (sno='0')
				then Next_state <= s0;
				else Next_state <= s1;
				end if;
			when s1 =>
				if (x(0)='1')
				then Next_state <= s2;
				else Next_state <= s3;
				end if;
			when s2 | s3 =>
				if (x(1)='0' and x(0)='1')
					then Next_state <= s2;
				elsif (x(1)='0' and x(0)='0')
					then Next_state <= s3;
				elsif (x(1)='1' and x(2)='1')
					then Next_state <= s4;
				elsif (x(1)='1' and x(2)='0')
					then Next_state <= s5;
				end if;
			when s4 =>
				Next_state <= s5;
			when s5 =>
				Next_state <= s0;
		end case;
	end process Next_s;
	
	y <= "000000111" when Next_state=s1 else
		  "011101000" when Next_state=s2 else
		  "011110000" when Next_state=s3 else
		  "100000000" when Next_state=s4 else
		  "000000000";
	
	sko <= '1' when state=s5 else '0';
	
	state <= s0 when set='1' else
	Next_state when clk'event and clk='1'
	else state;

end Mur_arch;