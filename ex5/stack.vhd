library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity stack is
generic (max: std_logic_vector:= "111");
port (stin                   	 : in std_logic_vector;   -- input data
	  reset,clk,push,pop         : in std_logic;          -- reset, clock, push, and pop signals
	  stout 				     : out std_logic_vector;  -- output data
	  empty,full 			     : out std_logic); 	      -- signals indicating the stack emptiness and fullness
end entity;

architecture stack_behav of stack is
signal pointer, next_pointer : std_logic_vector(max'length downto 0);
signal address_s, next_address : std_logic_vector(max'length-1 downto 0);
signal data_s : std_logic_vector(stin'length-1 downto 0);
signal nextdatain, datain : std_logic_vector(stin'length-1 downto 0);
signal cs_s, rw_s, oe_s : std_logic;
signal next_rw, next_oe : std_logic;

 -- Funtion——or operation of vector
function function_or (vector: std_logic_vector) return std_logic is
variable inputvector : std_logic_vector(vector'length-1 downto 0);
variable result : std_logic;
begin
	inputvector := vector;
	result := '0';
	for i in 0 to inputvector'length-1 loop
	  result := result or inputvector(i);
	end loop;
return result;
end function_or;


begin  -- stack_behav

-----------------------------------------------------------------------------
-- Memory instantiation.
-----------------------------------------------------------------------------
memory : entity sp_ram
		generic map (
		  data_width => stin'length,
		  addr_width => max'length)
		port map (rw      => rw_s,
				  oe      => oe_s,
				  cs      => cs_s,
				  address => address_s,
				  data    => data_s);

-----------------------------------------------------------------------------
-- Concurrent assignments.
-----------------------------------------------------------------------------


-- full and empty 
empty <= '1' when function_or(pointer(pointer'left-1 downto 0)) = '0'
	   and pointer(pointer'left) = '0' else '0';
full <= '1' when function_or(pointer(pointer'left-1 downto 0)) = '0'
	  and pointer(pointer'left) = '1' else '0';



data_s <= datain;
stout(stout'left downto 0) <= data_s when oe_s = '1' else (others => 'Z');
cs_s <= '1';
-----------------------------------------------------------------------------
-- Combinational process.
-----------------------------------------------------------------------------
combinational : process (pointer, push, pop, stin)
variable temp : unsigned(pointer'length-1 downto 0);

begin
	-- rw oe  by  pop/push
	next_rw <= (not pop) and push;           -- pop/push->rw
	next_oe <= pop;                          -- read output


	if push = '1' then          --push
		if function_or(pointer(pointer'left-1 downto 0)) = '0'      --full
		and pointer(pointer'left) = '1' then
		next_pointer <= pointer;
		next_address <= address_s;
		nextdatain <= data_s;		
	  else
		temp :=  unsigned(pointer) + to_unsigned(1,pointer'length);
		next_pointer <= std_logic_vector(temp);
		next_address <= pointer(next_address'left downto 0);		
		nextdatain <= stin;
	  end if;	  
	elsif pop = '1' then		--pop   
	  if function_or(pointer(pointer'left-1 downto 0)) = '0'      --empty
		and pointer(pointer'left) = '0' then
		next_pointer <= pointer;
		next_address <= address_s;		
	  else
		temp := unsigned(pointer) - to_unsigned(1,pointer'length);
		next_pointer <= std_logic_vector(temp);
		next_address <= std_logic_vector(temp(next_address'left downto 0));
	  end if;
	  nextdatain <= (others => 'Z');	
	else   -- qita 
	  next_pointer <= pointer;
	  next_address <= address_s;
	  nextdatain <= (others => 'Z');
	end if;

end process combinational;

-----------------------------------------------------------------------------
-- Sequential process.
-----------------------------------------------------------------------------
sequential : process (reset, clk)
begin
	if reset = '1' then
		datain <= (others => 'Z');
		address_s <= (others => '0');
		oe_s <= '0';
		rw_s <= '0';
		pointer <= (others => '0');
	elsif clk'event and clk = '1' then
		pointer <= next_pointer;
		datain <= nextdatain;
		address_s <= next_address;
		oe_s <= next_oe;
		rw_s <= next_rw;
	end if;
end process sequential;

end architecture stack_behav;
