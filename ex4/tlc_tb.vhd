library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity tlc_tb is
  
end tlc_tb;

architecture behavior of tlc_tb is
  signal rst, clk_s : std_logic;              -- Reset and clock.
  signal timer_start, timer_end, blink : std_logic;  -- Timer control.
  signal timer_period : std_logic_vector(2 downto 0);  -- Timer data.
  signal hw_sensor1, hw_sensor2 : std_logic;  -- Highway sensors.
  signal fr_sensor1, fr_sensor2 : std_logic;  -- Farm sensors.
  signal clk_stop : std_logic := '0';
  signal hwlight_out, frlight_out : std_logic_vector(2 downto 0);

  -----------------------------------------------------------------------------
  -- Function to get the light vector based on a string.
  -----------------------------------------------------------------------------
  function get_light_vector(light : string)
    return std_logic_vector is
    variable vector : std_logic_vector(2 downto 0);
  begin
    if light = "red" then
      vector := "100";
    elsif light = "yellow" then
      vector := "010";
    elsif light = "green" then
      vector := "001";
    elsif light = "redyellow" then
      vector := "110";
    elsif light = "blank" then
      vector := "000";
    else
      vector := "111";
    end if;
    
    return vector;
  end function get_light_vector;
  
  -----------------------------------------------------------------------------
  -- Procedure to execute an assert statement on the light status lines.
  -- delay : delay before executing assert statement.
  -- hw_light : String for the state to test in hw_light signal.
  -- fr_light : String for the state to test in fr_light signal.  
  -----------------------------------------------------------------------------
  procedure light_assert (constant hw_light : string;
                          constant fr_light : string) is
  begin
     assert hwlight_out = get_light_vector(hw_light)
       and frlight_out = get_light_vector(fr_light)
      report "Failed when checking " & hw_light
       & " - " & fr_light
      severity error;
  end procedure light_assert;


begin  
  
  -----------------------------------------------------------------------------
  -- Units under test instantiation.
  -----------------------------------------------------------------------------
  uut1 : entity timer port map (
    rst => rst, clk => clk_s, timer_start => timer_start,
    timer_period => timer_period, timer_end => timer_end);

  uut2 : entity tlc port map (
    rst =>rst, clk => clk_s, timer_start => timer_start, timer_end => timer_end,
    timer_period => timer_period, blink => blink, hw_sensor1 => hw_sensor1, hw_sensor2 => hw_sensor2,
    fr_sensor1 => fr_sensor1, fr_sensor2 => fr_sensor2,hwlight_out => hwlight_out, frlight_out => frlight_out);
  
  -----------------------------------------------------------------------------
  -- Process for controller's clock signal generation.
  -----------------------------------------------------------------------------
  clock_gen: process
    constant duty_cycle: real := 0.50;
    constant period: time := 30518 ns;  -- 32.768KHz 
    constant clk_high: time := duty_cycle * period;
 
  begin
    while clk_stop = '0' loop
      clk_s <= '0';
      wait for period - clk_high; -- clock low time
      clk_s <= '1';
      wait for clk_high; -- clock high time
    end loop;
    wait;
  end process clock_gen;

  -----------------------------------------------------------------------------
  -- Process for sensors.
  -----------------------------------------------------------------------------
  sensor : process
  begin
    -- Initialize signals.
    hw_sensor1 <= '0';
    hw_sensor2 <= '0';
    fr_sensor1 <= '0';
    fr_sensor2 <= '0';
    blink <= '0';
    wait until rst = '1';

    -- Activate farm sensor 1. Timeline 15 sec after reset.
    wait for 15 sec;
    fr_sensor1 <= '1';
    wait for 1 sec;
    fr_sensor1 <= '0';

    -- Activate farm sensor 2 - Timeline 35 sec after reset.
    wait for 19 sec;
    fr_sensor2 <= '1';
    wait for 1 sec;
    fr_sensor2 <= '0';

    -- Activate highway sensor 1 - Timeline: 46 sec after reset.
    wait for 10 sec;
    hw_sensor1 <= '1';
    wait for 1 sec;
    hw_sensor1 <= '0';

    -- Activate blink signal - Timeline: 65 sec after reset.
    wait for 18 sec;
    blink <= '1';

    -- Deactivate blink signal - Timeline:  sec after reset.
    wait for 3 sec;
    blink <= '0'; 
  wait;  
  end process sensor;
  
-------------------------------------------------------------------------------
-- Process for testing.
-------------------------------------------------------------------------------
  test: process
    variable pulseCounter : integer;
    
  begin  -- process test
    
    -- Reset signal to board.
    rst <= '0';
    wait until clk_s = '1';
    rst <= '1';

    -- Error to test testbench :S
    --wait for 3 sec;
    
    -- Check green-red.
    wait for 33 sec;
    light_assert("green","red");

    -- Check yellow-red.
    wait for 3 sec;
    light_assert("yellow","red");
 
    -- Check red-red.
    wait for 2 sec;
    light_assert("red","red");

    -- Check red-redyellow.
    wait for 2 sec;
    light_assert("red","redyellow");
    
    -- Check red-green.

	wait for 2 sec;
    light_assert("red","green");

    -- Check red-green.
   
	wait for 6 sec;
    light_assert("red","green");
    
    -- Check red-yellow.
    
	wait for 5 sec;  
    light_assert("red","yellow");

    -- Check red-red.
    wait for 2 sec;
    light_assert("red","red");

    -- Check redyellow-red.
    wait for 2 sec;
    light_assert("redyellow","red");

    -- Check green-red.
    wait for 2 sec;
    light_assert("green","red");

    wait for 5750 ms;   -- Wait to synchronize.
   -- wait for 0.5 sec;
    for i in 0 to 2 loop                -- Check blink cycle 3 times.
      
      -- Check blank-blank.
      --wait for 500 ms;
	  wait for 0.5 sec;
      light_assert("blank","blank");

      -- Check yellow-yellow.
      --wait for 500 ms;
	  wait for 0.5 sec;
      light_assert("yellow","yellow");
      
    end loop;  -- i

    -- Check green-red.
    wait for 3 sec;
    light_assert("green","red");
    
    -- Finish simulation.
    clk_stop <= '1';
    
    wait;
  end process test;
  
end behavior;