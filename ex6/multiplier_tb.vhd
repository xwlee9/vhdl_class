library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity multiplier_tb is
	generic(	a_width_t: integer:= 4;
				b_width_t: integer:= 4);
end entity;

architecture behav of multiplier_tb is
component p_mul
	generic(	a_width: integer;
				b_width: integer);
	port(	    a_vec: in std_logic_vector(a_width - 1 downto 0);
				b_vec: in std_logic_vector(b_width - 1 downto 0);
				sum: out std_logic_vector((a_width + b_width) - 1 downto 0));
end component;

signal a_t: std_logic_vector(a_width_t - 1 downto 0);
signal b_t: std_logic_vector(b_width_t - 1 downto 0);
signal sum_t: std_logic_vector((a_width_t + b_width_t) - 1 downto 0);

begin
	pm: component p_mul
		generic map(a_width_t, b_width_t)
		port map(a_t, b_t, sum_t);
		
	tb_p: process
		variable loop_counter1 : integer range 0 to 15 ;
		variable loop_counter2 : integer range 0 to 15 ;
	begin
		for loop_counter1 in 0 to 15 loop
			a_t <= conv_std_logic_vector(loop_counter1,4);
			for loop_counter2 in 0 to 15 loop
				b_t <= conv_std_logic_vector(loop_counter2,4);			  
				wait for 10 ns;
			end loop;
		end loop;
	end process;
end architecture;