library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;


entity sp_ram_test is  
end sp_ram_test;

architecture sp_ram_test_behav of sp_ram_test is
signal cs, rw, oe:std_logic;
signal address:std_logic_vector(2 downto 0);
signal data:std_logic_vector(15 downto 0);
begin 

uut1 :  entity sp_ram
		generic map (
		  data_width => 16,
		  addr_width => 3)
		port map (
			address => address,
			data    => data,
			cs      => cs,
			rw      => rw,
			oe      => oe);
  
   -- test process.
test :process
variable num1 :integer;
begin  
    -- Initial
	cs<='0';  
	oe<='0';
	rw<='0';
	
	wait for 10 ns;
	
	--write operation
	cs<='1';
	for i in 0 to 7 loop
		address<=std_logic_vector(to_unsigned(i,address'length));
		data<=std_logic_vector(to_unsigned(i,data'length));
		wait for 10 ns;
		rw<='1';
		wait for 10 ns;
		rw<='0';
	end loop;
-------------------------------

--------------------------------	
	--rw<='0';
	
	oe<='1';
	cs<='0';	
	data<=(others=>'Z');
	wait for 10 ns;
	
	--read and test
	for j in 0 to 7 loop
		address<=std_logic_vector(to_unsigned(j,address'length));
		wait for 10 ns;
		cs<='1';
		wait for 10 ns;
		num1:=to_integer(unsigned(data));
		assert num1=j
			report "wrong read number of " & integer'image(j)
			severity error;
		wait for 10 ns;
		cs<='0';
	end loop;	

    wait;
	
end process test;
    

  
end architecture sp_ram_test_behav;
