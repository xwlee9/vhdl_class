LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY bcd_2_bar_tb IS
END ENTITY bcd_2_bar_tb;

ARCHITECTURE test OF bcd_2_bar_tb IS  
COMPONENT bcd_2_bar
  PORT(bcd: IN std_logic_vector(3 DOWNTO 0);
       bar_graph: OUT std_logic_vector(8 DOWNTO 0));
END COMPONENT;
  
SIGNAL bcd:std_logic_vector(3 DOWNTO 0);
SIGNAL bar_graph:std_logic_vector(8 DOWNTO 0);
  
TYPE test_record IS RECORD
  		bcd_array : 		    std_logic_vector(3 downto 0);
		bar_graph_array : std_logic_vector(8 downto 0);
END RECORD;
	
TYPE search_array IS ARRAY (natural RANGE <>) OF test_record;
CONSTANT data:search_array:=
    (("0000", "111111111"),
     ("0001", "111111110"),
     ("0010", "111111100"),
     ("0011", "111111000"),
     ("0100", "111110000"),
     ("0101", "111100000"),
     ("0110", "111000000"),
     ("0111", "110000000"),
     ("1000", "100000000"),
     ("1001", "000000000"),
     ("1010", "000000000"),
     ("1011", "000000000"),
     ("1100", "000000000"),
     ("1101", "000000000"),
     ("1110", "000000000"),
     ("1111", "000000000"));
BEGIN
  dut:bcd_2_bar PORT MAP(bcd,bar_graph);
  PROCESS
  BEGIN
    FOR i IN data'RANGE
      LOOP
      bcd <= data(i).bcd_array;
      WAIT FOR 10 ns;
      ASSERT bar_graph = data(i).bar_graph_array
        REPORT "error!Your inputs are invalid."
        SEVERITY error;
      END LOOP;
  END PROCESS;
END test;