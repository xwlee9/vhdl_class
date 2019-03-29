library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tlc is
  port (
    rst                      : in  std_logic;  -- Reset ACTIVE LOW.
    clk                      : in  std_logic;  -- Clock signal.
    hw_sensor1, hw_sensor2   : in  std_logic;  -- Highway sensors.
    fr_sensor1, fr_sensor2   : in  std_logic;  -- Farm road sensors.
    blink                    : in  std_logic;  -- Blink state signal.
    hwlight_out              : out std_logic_vector(2 downto 0);
    frlight_out              : out std_logic_vector(2 downto 0);

    -- Timer interface.
	  timer_end                     : in  std_logic;                        -- Timer end signal
    timer_start                   : out std_logic;                        -- Timer start signal.   
    timer_period                  : out std_logic_vector(2 downto 0));    -- Timer period.
end tlc;

architecture behavior of tlc is
type t_light_color is (blank, red, yellow, redyellow, green);--5
type m_state is (gr1, gr2, rg1, rg2, yr_to_rr, yr_to_gr, ry_to_rr, ry_to_rg, rr_to_yr, rr_to_ry, yy, bb);--12
signal present_state, next_state    : m_state;
signal next_timer_period            : std_logic_vector(2 downto 0);  -- Next timer period.
signal next_timer_start             : std_logic;
signal hw_light, fr_light           : t_light_color;        --deng yanse
signal timer_start_s                : std_logic;
signal timer_period_s               : std_logic_vector(2 downto 0);
     --Time
constant T0_5 : std_logic_vector(2 downto 0)  := "000";
constant T2   : std_logic_vector(2 downto 0)  := "001";
constant T5   : std_logic_vector(2 downto 0)  := "010";
constant T10  : std_logic_vector(2 downto 0)  := "011";
constant T30  : std_logic_vector(2 downto 0)  := "100";

begin

  with present_state select
    hw_light <=
    green     when gr1 | gr2,
    yellow    when yr_to_rr | yy,
    redyellow when yr_to_gr,
    red       when rg1 | rg2 | ry_to_rr | ry_to_rg | rr_to_yr | rr_to_ry,
    blank     when bb;
  with hw_light select
    hwlight_out <=
    "001" when green,
    "010" when yellow,
    "110" when redyellow,
    "100" when red,
    "000" when blank;
  
  
  with present_state select
    fr_light <=
    green     when rg1 | rg2,
    yellow    when ry_to_rr | yy,
    redyellow when ry_to_rg,
    red       when gr1 | gr2 | yr_to_rr | yr_to_gr | rr_to_yr | rr_to_ry,
    blank     when bb;
  with fr_light select
    frlight_out <=
    "001" when green,
    "010" when yellow,
    "110" when redyellow,
    "100" when red,
    "000" when blank;

    timer_start  <= timer_start_s;
    timer_period <= timer_period_s;	
	
  nextstate:process (present_state, timer_end, blink, hw_sensor1, hw_sensor2,
                      fr_sensor1, fr_sensor2)
  begin
         
    -- Blink signal activates.
    if (blink = '1') and (present_state /= bb) and (present_state /= yy) then
      next_state <= bb;
      next_timer_period <= T0_5;
      next_timer_start <= '1';

    -- Blink signal deactivates.

    elsif (blink = '0') and ((present_state = bb) or (present_state = yy)) then
      next_state <= gr1;
      next_timer_period <= T30;            
      next_timer_start <= '1';
          
    -- Highway sensors.
    elsif (hw_sensor1='1' or  hw_sensor2='1') and present_state = rg2 then
      next_state <= rg1;
      next_timer_period <= T5;
      next_timer_start <= '1';
 
    -- Farm road sensors.
    elsif (fr_sensor1='1' or fr_sensor2='1') and present_state = gr2 then
      next_state <= yr_to_rr;
      next_timer_period <= T2;     
      next_timer_start <= '1';
      
    elsif timer_end = '1' then
      
      -- Check present state.
      case present_state is     
        when gr1 =>                   --gr1 or gr2 ==> yr_to_rr
		    next_state <= gr2;
			next_timer_start <= '0';	
		
            
        when yr_to_rr =>              -- yr_to_rr  ==> rr_to_ry
          next_state <= rr_to_ry;
          next_timer_period <= T2;
          next_timer_start <= '1';
           
        when rr_to_ry =>              -- rr_to_ry  ==> ry_to_rg
          next_state <= ry_to_rg;
          next_timer_period <= T2;
          next_timer_start <= '1';
           
        when ry_to_rg =>              -- ry_to_rg  ==> rg1 or rg2
          next_state <= rg2;
          next_timer_period <= T10;
          next_timer_start <= '1';

        when rg1 =>  
				next_state <= ry_to_rr;
				next_timer_period <= T2;
				next_timer_start <= '1';
            --end if;	
	     	when rg2 => 	                 -- rg1 or rg2==> ry_to_rr;
				next_state <= ry_to_rr;
				next_timer_period <= T2;
				next_timer_start <= '1';
              
                      
        when ry_to_rr =>              -- ry_to_rr==> rr_to_yr;
          next_state <= rr_to_yr;
          next_timer_period <= T2;
          next_timer_start <= '1';
           
        when rr_to_yr =>              -- rr_to_ry==> yr_to_gr;
          next_state <= yr_to_gr;
          next_timer_period <= T2;
          next_timer_start <= '1';

        when yr_to_gr =>              -- yr_to_gr==> gr1 or gr2
          next_state <= gr1;
          next_timer_period <= T30;
          next_timer_start <= '1';
            
        when bb =>                    
          next_state <= yy;
          next_timer_period <= T0_5;
          next_timer_start <= '1';

        when yy =>                   
          next_state <= bb;
          next_timer_period <= T0_5;
          next_timer_start <= '1';
                                
        when others => null;
      end case;
      
    else
      -- No change.
      next_state <= present_state;
      next_timer_period <= timer_period_s;
      next_timer_start <= '0';
    end if;

  end process;
  	 
  -----------------------------------------------------------------------------
  -- Current state process.
  -----------------------------------------------------------------------------
  currentstate : process (rst, clk)
  begin
    if rst = '0' then                          -- Asynchronous reset.
      present_state <= gr1;
      timer_period_s <= T30;
      timer_start_s <= '1';
    elsif clk'event and clk = '1' then         -- Wait for rising edge.
      timer_period_s <= next_timer_period;
      present_state <= next_state;
      timer_start_s <= next_timer_start;
    end if;
  end process;
  end behavior;
