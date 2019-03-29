library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity p_mul is
	generic(	a_width: integer;
				b_width: integer);
	port(	    a_vec: in std_logic_vector (a_width - 1 downto 0);
				b_vec: in std_logic_vector (b_width - 1 downto 0);
				sum:  out std_logic_vector ((a_width + b_width) - 1 downto 0));
end entity;

architecture behav of p_mul is
	component one_mul
		port(	a, b: in std_logic;
				sin:  in std_logic;
				cin:  in std_logic;
				sout: out std_logic;
				cout: out std_logic);
	end component;
	
	type gen_matrix is array(b_width - 1 downto 0) of std_logic_vector(a_width - 1 downto 0);
	signal carry_matrix, sum_matrix: gen_matrix:= (others => (others => '0'));

begin
	generate_multiplier: for i in 0 to (b_width-1) generate
	begin
		fisrt_line: if i = 0 generate
		begin
			first: for j in 0 to (a_width-1) generate
			begin
				first_first: if j = 0 generate
				begin
					cell: component one_mul
					port map(a_vec(j), b_vec(i), '0', '0', sum(i), carry_matrix(i)(j));
				end generate first_first;
				first_middle: if j > 0 generate
				begin
					cell: component one_mul
					port map(a_vec(j), b_vec(i), '0', '0', sum_matrix(i)(j-1), carry_matrix(i)(j));
				end generate first_middle;	
				first_last: if j = (a_width-1) generate
				begin
					cell: component one_mul
					port map(a_vec(j), b_vec(i), '0', '0', sum_matrix(i)(j-1), sum_matrix(i)(j));
				end generate first_last;
			end generate first;
		end generate fisrt_line;
		
		other_lines: if i /= 0 generate
		begin
			other: for j in 0 to (a_width-1) generate
			begin
				other_first: if j = 0 generate
				begin
					cell: component one_mul
					port map(a_vec(j), b_vec(i), sum_matrix(i-1)(j), '0', sum(i), carry_matrix(i)(j));
				end generate other_first;
				
				other_middle: if j /= 0 and j /= a_width - 1 generate
				begin
					cell: component one_mul
					port map(a_vec(j), b_vec(i), sum_matrix(i-1)(j), carry_matrix(i)(j-1), sum_matrix(i)(j-1), carry_matrix(i)(j));
				end generate other_middle;
				
				other_last: if j = (a_width-1) generate
				begin
					cell: component one_mul
					port map(a_vec(j), b_vec(i), '0', carry_matrix(i)(j-1), sum_matrix(i)(j-1), sum_matrix(i)(j));
				end generate other_last;
			end generate other;
		end generate other_lines;
	end generate generate_multiplier;

	sum(a_width + b_width - 1) <= sum_matrix(b_width-1)(a_width-1);
	sum(a_width + b_width - 2 downto b_width) <= sum_matrix(b_width - 1)((b_width - 2) downto 0);
end architecture;