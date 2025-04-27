library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

 
entity ControlUnit is
    port
    (
        y:   out  std_logic_vector(0 to 9);  
        x:   in   std_logic_vector(0 to 1);  
        clk: in   std_logic;                 
        set: in   std_logic;                 
        sno: in   std_logic;                 
        sko: out  std_logic                  
    );
end ControlUnit;

 
architecture arch_mealy of ControlUnit is
    type T_state is (s0, s1, s2, s3);  
    signal state, next_state : T_state;
    begin
        NS: process(state, sno, x)
        begin
            sko<='0';
            y<="0000000000";
        
            case state is
                when s0 =>
                    if (sno = '1') then
                         
                        next_state <= s1; 
                        y <= "1111000000";
                    else
                         
                        next_state <= s0;
                        y <= "0000000000";
                    end if;
                
                when s1 =>
                    if (x(0) = '0') then
                        if (x(1) = '1') then
                             
                            y <= "0000100000";
                        end if;
                        next_state <= s2;
                    else 
                        if (x(1) = '1') then
                             
                            y <= "0000010000";
                        end if;
                        next_state <= s3;
                    end if;
                
                when s2 =>
                     
                    y <= "0000001110";
                    next_state <= s1;
                
                when s3 =>
                     
						  y <= "0000000001";
                    sko <= '1';
                    next_state <= s0;
                
                when others =>
                    null;
            end case;
    end process NS;
        
    state <= s0         when set = '1' else               
             next_state when rising_edge(clk) else        
             state;

end architecture arch_mealy;

architecture arch_moore of ControlUnit is
    type T_state is(s0,s1,s2,s3,s4,s5);  
    signal state,Next_state:T_state;  
       begin
       NS:process(state,x,sno)  
                                
        begin
        Next_state<=s0;  
        case state is
        when s0 => 
            if(sno='1') then 
                Next_state<=s1;  
                else Next_state<=s0;  
            end if;
        when s1 =>
            if(x="11") then  
                Next_state <= s4;  
            elsif (x="10") then  
                Next_state <= s5;  
            elsif (x="01") then
                Next_state <= s2;  
            end if;
        when s2 => Next_state<=s3;  
        when s3 =>  
            if(x="11") then  
                Next_state <= s5;  
            elsif(x="10") then
                Next_state <= s4;  
            elsif(x="01") then
                Next_state <= s2;
            else
                Next_state <= s3;
        end if;
        when s4 =>  
            Next_state <= s5;
        when s5 => 
            Next_state <= s0;  
    end case;
    end process NS;

    y<="1111000000" when state=s1 else     
         "0000100000" when state=s2 else     
         "0000001110" when state=s3 else     
         "0000010000" when state=s4 else     
         "0000000001" when state=s5;         

    sko<='1' when state=s5 else '0';  
         
      
    state <= s0         when set ='1' 
    else  
             Next_state when clk'event and clk='0'  
    else     state;  
end arch_moore;
    



