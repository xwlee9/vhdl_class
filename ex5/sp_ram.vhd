library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sp_ram is
generic ( data_width:integer:=16;
          addr_width:integer:=3);
port(address:in std_logic_vector(addr_width-1 downto 0);  --address input
     data:inout std_logic_vector(data_width-1 downto 0);  --data
	 cs:in std_logic;        --chip select
	 rw:in std_logic; 		 --read/write enable	
	 oe:in std_logic);	     --output enable
end entity sp_ram;

architecture sp_ram_behav of sp_ram is
subtype memA is std_logic_vector(data'length-1 downto 0);
type memB is array (0 to (2**addr_width-1)) of memA;
begin
	process (cs,rw,oe,data,address)
	variable memory:memB;
	begin
		if cs='1' then
			if rw='1' then
				memory(to_integer(unsigned(address))):=data;
			else   --rw='0'
				if oe='1' then   --read operation
					data<=memory(to_integer(unsigned(address)));
				else             --to high impedance
					data<=(others=>'Z');
				end if;
			end if;	
		else   --cs='0'       to high impedance
			data<=(others=>'Z');
		end if;
	end process;
end architecture sp_ram_behav;	

  
		 