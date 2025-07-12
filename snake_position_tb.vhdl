library IEEE;
use IEEE.std_logic_1164.all;


entity snakepositioning_tb is
end entity;

architecture testbench of snakepositioning_tb is

component snakeposition is
port(	clk 	: in std_logic;
         up_en   : in std_logic;
         down_en : in std_logic;
         right_en: in std_logic;
         reset_en : in std_logic;
         left_en : in std_logic;
         size_en : in std_logic;
         write_en : in std_logic;
         lose_s  : out std_logic;
         win_s : out std_logic;
         translator_en : out std_logic;
         newhead_x : out std_logic_vector(5 downto 0); -- x coordinate for updated head position 
         newhead_y : out std_logic_vector(5 downto 0); -- y coordinate for updated head position 
         oldtail_x : out std_logic_vector(5 downto 0); -- x coordinate for the previous tail position 
         oldtail_y : out std_logic_vector(5 downto 0)); -- y coordinate for the previous tail position 

end component;

-- signals
signal clk : std_logic := '0';
signal write_en : std_logic := '0';
signal up_en : std_logic := '0';
signal down_en : std_logic := '0';
signal right_en : std_logic := '0';
signal reset_en : std_logic := '0';
signal size_en : std_logic := '0';
signal left_en : std_logic := '0';
signal win_s : std_logic := '0';
signal lose_s : std_logic := '0';
signal newhead_x : std_logic_vector(5 downto 0) := "000000";
signal newhead_y : std_logic_vector(5 downto 0) := "000000";
signal oldtail_x : std_logic_vector(5 downto 0) := "000000";
signal oldtail_y : std_logic_vector(5 downto 0) := "000000";

-- time
constant clk_period : time := 20ns;

BEGIN

uut : snakeposition PORT MAP(
	clk => clk,
    write_en => write_en,
    reset_en => reset_en,
    size_en => size_en,
    up_en => up_en,
    down_en => down_en,
    right_en => right_en,
    left_en => left_en,
    win_s => win_s,
    lose_s => lose_s,
    newhead_x => newhead_x,
    newhead_y => newhead_y,
    oldtail_x => oldtail_x,
    oldtail_y => oldtail_y);
    
-- clock process
clk_proc : process
begin
	clk <= not(clk);
    wait for clk_period/2;
end process clk_proc;


-- stimulus process
stim_proc : process
begin
	wait for clk_period*2;
    
    write_en <= '1'; --start writing new head and old tail
    
    wait for clk_period;
    
    right_en <= '1'; -- right button pressed
    
    wait for clk_period*1000;
    
    right_en <= '0';
    
    wait for clk_period*5;
    
    down_en <= '1'; -- down button pressed
    
    wait for clk_period*1000;
    
    down_en <= '0';
    
    wait for clk_period*5;
    
    left_en <= '1'; --left button pressed
    
    wait for clk_period*1000;

    wait;
    
 end process stim_proc;
 
 end testbench;
