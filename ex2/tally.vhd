library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tally is 
 port ( scoresA, scoresB : in std_logic_vector (2 downto 0);  
 winner : out std_logic_vector (1 downto 0)); 
 end tally;
 architecture loopy of tally is
  begin decision: process (scoresA,scoresB) 
                 variable wintimes_A,wintimes_B:integer;                           --why we can't put this sentence on the line 14
                 begin 
                  
                  wintimes_A:=0;
                  wintimes_B:=0;
                  for loop_counter in 0 to 2 loop                                  --loop_counter represents the threr judges from 0 to 2
                     if (scoresA(loop_counter)='1' and scoresB(loop_counter)='0')    --if one judge gives his point to A/B, then A/B wins once  
                        then wintimes_A:=wintimes_A+1;
                     elsif (scoresA(loop_counter)='0' and scoresB(loop_counter)='1')
                        then wintimes_B:=wintimes_B+1;
                     elsif (scoresA(loop_counter)='1' and scoresB(loop_counter)='1') --if one point is given to both A and B, then both wintimes plus one
                        then wintimes_A:=wintimes_A+1; 
                             wintimes_B:=wintimes_B+1;                     
                     end if;
                  end loop; 
                  
                  if wintimes_A > wintimes_B then winner <= "10";   report"A win";               --compare wintimes of A and B to determine the winner
                  elsif  wintimes_A < wintimes_B then winner <= "01";report"B win";
                  elsif  (wintimes_A=0 and wintimes_B=0) then winner <= "00"; report"No decision";
                  else   
                         winner <= "11";report"tie";
                  end if;
            end process;
end loopy;