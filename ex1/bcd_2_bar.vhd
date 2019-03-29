library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_2_bar IS
PORT ( bcd :in std_logic_vector(3 downto 0);
       bar_graph :out std_logic_vector(8 downto 0));
end bcd_2_bar;
architecture case_statement of bcd_2_bar is
begin
       bar_graph <= "111111111" when bcd="0000" else --0
       "111111110" when bcd="0001" else
       "111111100" when bcd="0010" else
       "111111000" when bcd="0011" else
       "111110000" when bcd="0100" else
       "111100000" when bcd="0101" else
       "111000000" when bcd="0110" else
       "110000000" when bcd="0111" else
       "100000000" when bcd="1000" else
       "000000000" ;
end case_statement;