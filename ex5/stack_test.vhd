library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity stack_test is
end stack_test;

architecture stack_test_behav of stack_test is
  signal clk, clk_stop 				: std_logic := '0';               -- Clock signals.
  signal stin, stout			    : std_logic_vector(16 downto 0);  -- Data.
  signal reset, push, pop 			: std_logic;                      -- Control signals.
  signal empty, full      		    : std_logic;                      -- Status signals.
  
begin  -- stack_test_behav

-----------------------------------------------------------------------------
--instantiation
-----------------------------------------------------------------------------
uut1 : entity stack
		generic map (max => "111")
		port map (
		  reset => reset,
		  clk    => clk,
		  stin   => stin,
		  stout  => stout,
		  push   => push,
		  pop    => pop,
		  empty  => empty,
		  full   => full);
  
-----------------------------------------------------------------------------
-- Clock generation
-----------------------------------------------------------------------------
clock : process
begin
	while clk_stop = '0' loop
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end loop;
	wait;
end process clock;
  
-----------------------------------------------------------------------------
-- test process.
-----------------------------------------------------------------------------
test : process
constant period : time := 1 ns;
begin
    -- reset
    reset <= '1';
    pop <= '0';
    push <= '0';
    stin <= (others => '0');
    wait until clk = '1';
    reset <= '0'; 

    -- Five cycles to check stack stays empty.
    for i in 0 to 4 loop
      wait until clk = '1';
      wait for period;
      assert empty = '1'
        report "stack is not empty before push operations"
        severity error;
    end loop;  
  
    -- Fill the stack, 3 memory cells.
    push <= '1';
    for i in 1 to 3 loop
      stin <= std_logic_vector(to_unsigned(i,stin'length));
      wait until clk = '1';
      wait for period;

      assert empty = '0'                -- Check "empty" signal.
        report "Stack reports empty at push number " & integer'image(i)
        severity error;
      if i = 8 then
        assert empty = '0'              -- Check "full" signal.
          report "Stack doesn't report full at push number " & integer'image(i)
          severity error;           
      end if;
    end loop; 

    -- Five cycles to test integrity of data saved.
    push <= '0';
    for i in 1 to 5 loop
      stin <= std_logic_vector(to_unsigned(i,stin'length));   -- Data change.
      wait until clk = '1';
    end loop;  
    
    -- Fill the stack, 5 memory cells.
    push <= '1';
    for i in 4 to 8 loop
      stin <= std_logic_vector(to_unsigned(i,stin'length));
      wait until clk = '1';
      wait for period;

      assert empty = '0'                -- Check "empty" signal.
        report "Stack reports empty at push number " & integer'image(i)
        severity error;
      if i = 8 then
        assert empty = '0'              -- Check "full" signal.
          report "Stack doesn't report full at push number " & integer'image(i)
          severity error;           
      end if;
    end loop; 

    -- Five cycles to check stack doesn't overwrite and stays full.
    push <= '1';
    for i in 0 to 4 loop
      stin <= std_logic_vector(to_unsigned(i,stin'length));  -- Data change.
      wait until clk = '1';
      wait for period;
      assert full = '1'                 -- Check full signal.
        report "Full check: full signal is not active at cycle number " & integer'image(i)
        severity error;
    end loop; 

    -- Read stack content, 5 cells.
    push <= '0';
    pop <= '1';
    for i in 8 downto 4 loop
      wait until clk = '1';
      wait for period;
      assert stout = std_logic_vector(to_unsigned(i,stout'length))
        report "Output data unexpected at pop number " & integer'image(i)
        severity error;

      assert empty = '0'                -- Check "empty" signal.
        report "Empty signal is active at pop number " & integer'image(i)
        severity error;  

      assert full = '0'                -- Check "full" signal.
        report "Pop signal is active at pop number " & integer'image(i)
        severity error;  
    end loop;  

    -- Five cycles to check stack integrity.
    pop <= '0';
    for i in 0 to 4 loop
      stin <= std_logic_vector(to_unsigned(i,stin'length));  -- Data change.
      wait until clk = '1';
    end loop;  

    -- Read stack content, 3 cells.
    pop <= '1';
    for i in 3 downto 1 loop
      wait until clk = '1';
      wait for period;
      assert stout = std_logic_vector(to_unsigned(i,stout'length))
        report "Pop test: Output data unexpected cycle number " & integer'image(i)
        severity error;

      assert full = '0'                 -- test full
        report "Full signal is active at pop number " & integer'image(i)
        severity error;
      
      if i = 1 then                     -- test empty
        assert empty = '1'
        report "empty signal is not active at cycle number " & integer'image(i)
        severity error;  
      end if;
    end loop; 

    pop <= '0';   
    clk_stop <= '1';                    -- End
    wait;
end process test;
  
end stack_test_behav;
