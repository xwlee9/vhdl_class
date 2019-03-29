library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
  port (
    rst               : in  std_logic;                      -- Reset, ACTIVE_LOW.
    clk               : in  std_logic;                      -- Clock signal.
    timer_start       : in  std_logic;                      -- Start counting.
    timer_period      : in  std_logic_vector(2 downto 0);   -- Time period.
	
    timer_end         : out std_logic);                     -- Count end.
end timer;


architecture behavior of timer is
  signal counter, limit   : unsigned(19 downto 0);          -- Counter and count limit.
  signal nextCounter      : unsigned(19 downto 0);          -- Next value for counter.
  signal nexttend         : std_logic;                      -- Next end value.
  signal counting         : std_logic;
  
  -----------------------------------------------------------------------------
  -- Time constants for 32.768 KHz clock.
  ----------------------------------------------------------------------------- 
  constant T0_5 : unsigned(19 downto 0) := "00000100000000000000";    --0.5s
  constant T2 : unsigned(19 downto 0) :=   "00010000000000000000";    --2s
  constant T5 : unsigned(19 downto 0) :=   "00101000000000000000";    --5s
  constant T10 : unsigned(19 downto 0) :=  "01010000000000000000";    --10s
  constant T30 : unsigned(19 downto 0) :=  "11110000000000000000";    --30s

  
begin  -- 
  
  -----------------------------------------------------------------------------
  -- Combinatorial process.
  -----------------------------------------------------------------------------
  combinatorial : process (timer_start, counter)
  begin  -- process 

    if timer_start = '1' then                -- Start counting.
      nextCounter <= to_unsigned(1,nextCounter'length); -- Reset counter.
      nexttend <= '0';
      counting <= '1';
      case timer_period is
        when "000" =>
          limit <= T0_5;     
        when "001" =>
          limit <= T2;       
        when "010" =>
          limit <= T5;      
        when "011" =>
          limit <= T10;      
        when "100" =>
          limit <= T30;      
        when others => null;
      end case;

    else
      nextCounter <= counter + 1;         -- Get next count.
      if counting = '1' then
        if nextCounter = limit then          -- Check for limit reached.
          nexttend <= '1';
          counting <= '0';
        else
          nexttend <= '0';
        end if;
      else
        nexttend <= '0';
      end if;
    end if;
  end process ;

  -----------------------------------------------------------------------------
  -- Sequential process.
  -----------------------------------------------------------------------------
  sequential: process (rst, clk)
  begin
    if rst = '0' then -- asynchronous reset
      timer_end <= '0';
      counter <= to_unsigned(0,counter'length); -- Reset counter.
    elsif clk'event and clk = '1' then
      counter <= nextCounter;
      timer_end <= nexttend;
    end if;
  end process ;
  
end behavior;

