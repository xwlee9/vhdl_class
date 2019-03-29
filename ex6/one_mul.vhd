library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity one_mul is
	port(	a,b:  in std_logic;
			cin:  in std_logic;
			sin:  in std_logic;
			sout: out std_logic;
			cout: out std_logic
	);
end entity;

architecture behav of one_mul is
	signal pp: std_logic;
begin
	pp <= a AND b; 
	cout <= (pp AND sin) OR (pp AND cin) OR (sin AND cin); 
	sout <= pp XOR sin XOR cin;
end architecture;