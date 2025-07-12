library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_shell_tb is
end top_shell_tb;

architecture testbench of top_shell_tb is

component top_level_shell is
    Port ( 	
			clk_ext_port		: in std_logic;		-- mapped to external IO device (100 MHz Clock)				
			H_sync_port			: out std_logic;    
			V_sync_port			: out std_logic;
			video_on_port       : out std_logic;
			right_ext_port      : in std_logic;
			left_ext_port       : in std_logic;
			down_ext_port       : in std_logic;
			up_ext_port         : in std_logic;
			start_ext_port      : in std_logic;    
			rgb_port			: out std_logic_vector(11 downto 0));    
end component;

signal clk_ext_port : std_logic := '0';
signal H_sync_port : std_logic := '0';
signal V_sync_port : std_logic := '0';
signal video_on_port : std_logic := '0';
signal right_ext_port : std_logic := '0';
signal left_ext_port : std_logic := '0';
signal down_ext_port : std_logic := '0';
signal up_ext_port : std_logic := '0';
signal start_ext_port : std_logic := '0';
signal rgb_port : std_logic_vector(11 downto 0) := "000000000000";

constant clk_period : time := 10ns;

begin

uut : top_level_shell port map(
    clk_ext_port => clk_ext_port,
    H_sync_port => H_sync_port,
    V_sync_port => V_sync_port,
    video_on_port => video_on_port,
    right_ext_port => right_ext_port,
    left_ext_port => left_ext_port,
    down_ext_port => down_ext_port,
    up_ext_port => up_ext_port,
    start_ext_port => start_ext_port,
    rgb_port => rgb_port);
    
-- clk process
clk_proc : process
begin
    clk_ext_port <= not(clk_ext_port);
    wait for clk_period/2;
end process clk_proc;

-- stim proc 
stim_proc : process
begin
    wait for clk_period*10;
    
    start_ext_port <= '1'; --starts game
    
    wait for clk_period*200;
    
    start_ext_port <= '0';
    
    wait for clk_period;
    
    down_ext_port <= '1'; --down button pressed
    
    wait for clk_period*1000;
    
    down_ext_port <= '0';
    
    wait for clk_period*50;
    
    right_ext_port <= '1'; --right button pressed
    
    wait for clk_period*1000;
    
    right_ext_port <= '0';
    
    wait for clk_period;
    
    wait;
end process stim_proc;

end testbench;
