library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt1 is 
port(reset,enable,load,downup,clk  : in   std_logic;
     data                          : in   std_logic_vector(3 downto 0);
	 count                         : out  std_logic_vector(3 downto 0);
	 over                          : out  std_logic
	 );
end cnt1;

architecture cnt1_behav of cnt1 is
begin
    count1:process
          variable count_int:integer:=0;
          variable over_v:std_logic:='0';
          begin
            -- count_int:=0;
			-- over_v:='0';
			wait until rising_edge(clk);
			if reset='1' then
			   count_int:=0;
			   over_v:='0';
			else
               if enable='0' then 
                  over_v:='0';
               else
                  if load='1' then   --load='1'
				     count_int:=to_integer(unsigned(data));
                     over_v:='0';
                  elsif downup='0' then
                        if count_int=15 then
						   count_int:=0;
						   over_v:='1';
						else  --count/=15
						   count_int:=count_int+1;
						   over_v:='0';
                        end if;						   
                  elsif downup='1' then					 
				        if count_int=0 then
						   count_int:=15;
						   over_v:='1';
                        else --count/=0
                           count_int:=count_int-1;
						   over_v:='0';
						end if;
                  end if;						

               end if;				  
            end if;
			count<=std_logic_vector(to_unsigned(count_int,count'length));
			over<=over_v;
	end process count1;
end cnt1_behav;		
			 
            			 
	            	  
	 