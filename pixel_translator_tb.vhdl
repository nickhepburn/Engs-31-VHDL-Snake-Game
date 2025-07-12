library IEEE;
use IEEE.std_logic_1164.all;


entity translator_tb is
end entity;

architecture testbench of translator_tb is

-- Component
component translator is
port(	clk		:	in	STD_LOGIC; --100 MHz clock
         reset   :   in std_logic;
         write_en: in std_logic;
         newhead_x :   in  std_logic_vector(5 downto 0);
         newhead_y :   in std_logic_vector(5 downto 0);
         oldtail_x :   in  std_logic_vector(5 downto 0);
         oldtail_y :   in std_logic_vector(5 downto 0);
         pixel_x	:	in std_logic_vector(9 downto 0);
         pixel_y	:	in std_logic_vector(9 downto 0);
         apple_x :   in std_logic_vector(5 downto 0);
         apple_y :   in std_logic_vector(5 downto 0);
         datapath_en : in std_logic;
         lose_signal : out std_logic;
         apple_enable : out std_logic;
         size_enable : out std_logic;
         rgb		:   out std_logic_vector(11 downto 0));
end component;

-- Signals
-- inputs
signal clk		:	STD_LOGIC := '0'; --100 MHz clock
signal reset   :   std_logic := '0';
signal write_en: std_logic := '0';
signal newhead_x :   std_logic_vector(5 downto 0) := "000000";
signal newhead_y :   std_logic_vector(5 downto 0) := "000000";
signal oldtail_x :   std_logic_vector(5 downto 0) := "000000";
signal oldtail_y :   std_logic_vector(5 downto 0) := "000000";
signal pixel_x	: std_logic_vector(9 downto 0) := "0000000000";
signal pixel_y	:	std_logic_vector(9 downto 0) := "0000000000";
signal apple_x :   std_logic_vector(5 downto 0) := "000000";
signal apple_y :   std_logic_vector(5 downto 0) := "000000";
signal datapath_en :  std_logic;

-- outputs
signal lose_signal : std_logic := '0';
signal apple_enable : std_logic := '0';
signal size_enable : std_logic := '0';
signal rgb		:   std_logic_vector(11 downto 0) := "000000000000";

-- time
constant clk_period : time := 20ns;

begin

-- port map
uut : translator
	port map(
    	clk => clk,
        reset => reset,
        write_en => write_en,
        newhead_x => newhead_x,
        newhead_y => newhead_y,
        oldtail_x => oldtail_x,
        oldtail_y => oldtail_y,
        pixel_x => pixel_x,
        pixel_y => pixel_y,
        apple_x => apple_x,
        apple_y => apple_y,
        datapath_en => datapath_en,
        lose_signal => lose_signal,
        apple_enable => apple_enable,
        size_enable => size_enable,
        rgb => rgb);
    
      
        

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
	--write a snake to top left corner to RGB, apple, and size signals
    datapath_en <= '1';
    write_en <= '1';
    apple_x <= "000000"; --put apple at top left corner 
    apple_y <= "000000";
    oldtail_x <= "001100"; --put tail in random location to start
    oldtail_y <= "001100";
    
    wait for clk_period;
    
    apple_x <= "001000"; --move apple from top left corner so that only snake head is there
    apple_y <= "001000";
   
 
    pixel_x <= "0000000001"; -- set pixel to something in top left corner
    pixel_y <= "0000000001";
    
    wait for clk_period*100;
    
    wait;
    
end process stim_proc;

end testbench;

