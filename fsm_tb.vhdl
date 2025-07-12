library IEEE;
use IEEE.std_logic_1164.all;


entity controller_tb is
end entity;

architecture testbench of controller_tb is

-- Component
component controller is
port(	 clk			: in std_logic;
         up_btn		: in std_logic;
         down_btn	: in std_logic;
         right_btn	: in std_logic;
         left_btn 	: in std_logic;
         start_btn	: in std_logic;
         win_game	: in std_logic;
         lose_game	: in std_logic;
         lose_signal_translator : in std_logic;
         write_en	: out std_logic;
         up_en		: out std_logic;
         down_en		: out std_logic;
         enable_apple: out std_logic;
         right_en	: out std_logic;
         left_en		: out std_logic;
         reset_en    : out std_logic);
end component;

-- Signals
-- inputs
signal clk : std_logic := '0';
signal up_btn : std_logic := '0';
signal down_btn : std_logic := '0';
signal right_btn : std_logic := '0';
signal left_btn : std_logic := '0';
signal start_btn : std_logic := '0';
signal win_game : std_logic := '0';
signal lose_game : std_logic := '0';
signal lose_signal_translator : std_logic := '0';

-- outputs
signal enable_apple : std_logic := '0';
signal reset_en : std_logic := '0';
signal write_en : std_logic := '0';
signal up_en : std_logic := '0';
signal down_en : std_logic := '0';
signal right_en : std_logic := '0';
signal left_en : std_logic := '0';

-- time
constant clk_period : time := 20ns;

begin

-- port map
uut : controller
	port map(
    	clk => clk,
        up_btn => up_btn,
        down_btn => down_btn,
        right_btn => right_btn,
        left_btn => left_btn,
        start_btn => start_btn,
        win_game => win_game,
        lose_game => lose_game,
        lose_signal_translator => lose_signal_translator,
        write_en => write_en,
        enable_apple => enable_apple,
        up_en => up_en,
        down_en => down_en,
        right_en => right_en,
        left_en => left_en);
        

-- Create the clock
clk_proc : process
begin
	clk <= not(clk);
    wait for clk_period/2;
    
end process clk_proc;



-- Stimulus process
stim_proc : process
begin
	wait for clk_period;
    
    start_btn <= '1'; -- start game
   	wait for clk_period;
    start_btn <= '0';
    
    wait for 2*clk_period;

	right_btn <= '1'; --right button pressed
    wait for clk_period;
    right_btn <= '0';
    
    wait for clk_period*2;
    
    up_btn <= '1'; -- up button pressed
    wait for clk_period;
    up_btn <= '0';
    wait for clk_period*2;
    
    left_btn <= '1'; --left button pressed
    wait for clk_period;
    left_btn <= '0';
    wait for clk_period*4;
    
    up_btn <= '1'; --up button pressed
    wait for clk_period;
    up_btn <= '0';
    wait for clk_period*6;
    
    right_btn <= '1'; --right button pressed
    wait for clk_period;
    right_btn <= '0';
    wait for clk_period * 2;
    
    down_btn <= '1'; -- down button pressed
    wait for clk_period;
    down_btn <= '0';
    wait for clk_period*2;
    
    left_btn <= '1'; --left button pressed
    wait for clk_period;
    left_btn <= '0';
    wait for clk_period*3;
    
    up_btn <= '1'; --up button pressed
    wait for clk_period;
    up_btn <= '0';
    wait for clk_period*2;
    
    win_game <= '1'; --win game asserted
    wait for clk_period;
    win_game <= '0';
    
    wait;
    
end process stim_proc;

end testbench;
