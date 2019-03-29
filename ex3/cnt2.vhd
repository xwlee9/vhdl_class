library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt2 is 
port(reset,enable,load,downup,clk  : in   std_logic;
     data                          : in   std_logic_vector(3 downto 0);
	 count                         : out  std_logic_vector(3 downto 0);
	 over                          : out  std_logic
	 );
end cnt2;

architecture cnt2_behav of cnt2 is
signal currentcnt_s   :integer;
signal nextcnt_s      :integer;
signal nextover_s     :std_logic;     
begin
     combinatorial:process(enable,load,downup,clk)
	 begin
	      if enable='0' then
		     nextcnt_s<=currentcnt_s;
			 nextover_s<='0';
		  else  --enable='1'
             if load='1' then
                nextcnt_s<=to_integer(unsigned(data));
                nextover_s<='0';
             else --load='0'
                if downup='0' then
				   if currentcnt_s=15 then
				      nextcnt_s<=0;
				      nextover_s<='1';
				   else
                      nextcnt_s<=currentcnt_s+1;
				      nextover_s<='0';
				   end if;	  
				else    --downup='1' 
                   if currentcnt_s=0 then
                      nextcnt_s<=15;
                      nextover_s<='1';
                   else
                      nextcnt_s<=currentcnt_s-1;
                      nextover_s<='0';	
                   end if;					  
                end if;
             end if;
          end if;
     end process combinatorial;

     register_logic:process(reset,clk)
	 begin	 
		  if reset='1' then
		     count<="0000";
			 over<='0';
			 currentcnt_s<=0;
		  elsif clk'event and clk='1' then
		     count<=std_logic_vector(to_unsigned(nextcnt_s,count'length));
			 over<=nextover_s;
			 currentcnt_s<=nextcnt_s;
		  end if;
     end process register_logic;

end cnt2_behav;	 
             		  
