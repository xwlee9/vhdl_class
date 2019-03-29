library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity testbench1 is
end testbench1;

architecture test_behav1 of testbench1 is
signal clk_stop                           : std_logic:='0';
signal reset,enable,load,downup,clk,over  : std_logic;
signal data,count                         : std_logic_vector(3 downto 0); 
begin
uut : entity cnt1 port map( reset => reset,enable => enable,  load => load,
downup => downup, clk => clk,over => over ,  data => data,   count => count); 

    clk_produce: process
	constant time_half : time:=5 ns;
    begin
         clk<='0';
		 wait for 10 ns;
		 while clk_stop = '0' loop
		       clk<='1';
			   wait for time_half;
			   clk<='0';
			   wait for time_half;
		 end loop;
    end process clk_produce;
	
	verify:process
	constant time_3:time:=3 ns;
    begin
	 --initial
	reset<='0';
	enable<='0';
	load<='0';
	downup<='0';
	
	--test reset
	reset<='1';
	wait until clk='1';
	wait for time_3;
	assert (count="0000") and (over='0')
	  report "reset test wrong!"
	  severity error;
	
	--test load
	reset<='0';
	enable<='1';
	load<='1';
	for i in 0 to 15 loop
	   data<=std_logic_vector(to_unsigned(i,data'length));
	   wait until clk='1';
	   wait for time_3;
	   assert (count=data) and (over='0')
	     report "load test wrong!"
		 severity error;
	end loop;
	
	--test upcount
	load<='1';
	data<="0000";
	wait until clk='1';
	wait for time_3;
	load<='0';
	downup<='0';
	for i in 1 to 16 loop
		wait until clk='1';
		wait for time_3;
		if i<16 then
			assert (to_integer(unsigned(count))=i) and (over='0')
				report "upcount test wrong for i="& integer'image(i)
				severity error;
        else
            assert (to_integer(unsigned(count))=0) and (over='1')
				report "upcount test wrong for overflow!"
				severity error;
		end if;		
	end loop;
    --test downcount
    load<='1';
    data<="1111";
    wait until clk='1';
    wait for time_3;
    load<='0';
    downup<='1';
	for i in 14 downto -1 loop
		wait until clk='1';
		wait for time_3;
		if i>-1 then
			assert(to_integer(unsigned(count))=i) and (over='0')
				report "downcount test wrong for i="& integer'image(i)
				severity error;	
		else
			assert(to_integer(unsigned(count))=15) and (over='1')
				report "downcount test wrong for overflow!"
				severity error;	
		end if;
	end loop;
	
	--clk_stop <= '1';

	
	end process verify;
end test_behav1;	
          