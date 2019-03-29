
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library std;
use std.env.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
entity tally_tb is 
  end tally_tb;
architecture test of tally_tb is  
  component tally
    port ( scoresA: in std_logic_vector (2 downto 0); 
           scoresB: in std_logic_vector (2 downto 0); 
           winner : out std_logic_vector (1 downto 0)); 
  end component; 
 signal scoresA :  std_logic_vector (2 downto 0);  
 signal scoresB :  std_logic_vector (2 downto 0);
 signal winner :  std_logic_vector (1 downto 0);


type test_inputs is array (7 downto 0) of std_logic_vector(2 downto 0);
constant input:test_inputs :=("000","001","010","100","011","101","110","111");

 TYPE test_record IS RECORD
  		scores_array : 		    std_logic_vector(2 downto 0);
  		num_array : 		    integer;
END RECORD;
TYPE search_array IS ARRAY (natural RANGE <>) of test_record;
CONSTANT data:search_array:=
(("000",0),--0-0
     ("001",1),--1-1
     ("010",1),--2-1
     ("011",2),--3-2
     ("100",1),--4-1
     ("101",2),--5-2
     ("110",2),--6-2
     ("111",3));--7-3
FUNCTION result (x,y:  std_logic_vector) RETURN  std_logic_vector IS
   variable a1:integer:=0;
   variable b1:integer:=0;
   variable z:std_logic_vector(1 downto 0);
      begin 
    for i in 0 to 7 loop
      if x=data(i).scores_array then
      a1:=data(i).num_array;
    end if;
       if y=data(i).scores_array then
      b1:=data(i).num_array;
    end if;
    end loop;
    if (a1>b1)
        then
          z:="01"; 
       elsif(a1<b1) then
          z:="10";  
        elsif (a1=0 and b1=0)  then
        z:="00"; 
      else z:="11"; 
      end if;
      return z;
    end function result;

     BEGIN
       dut:tally PORT MAP(scoresA => scoresA,scoresB => scoresB,winner => winner);
     process
       variable n1, n2: integer;
     begin    
    FOR n1 IN 7 downto 0 LOOP
        scoresA <= input(n1);
        for n2 in 7 downto 0 loop
            scoresB <= input(n2);
            wait for 10ns;
           assert not(winner=result(scoresA, scoresB)) 
        REPORT "error!"
        SEVERITY error;
      end loop ;
    end loop ;
    wait;
  end process;

END test;