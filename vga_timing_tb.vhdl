library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity VGA_tb is
end entity;

architecture testbench of VGA_tb is

component VGA is
    port(	clk		:	in	STD_LOGIC; --100 MHz clock
         V_sync	: 	out	STD_LOGIC;
         H_sync	: 	out	STD_LOGIC;
         video_on:	out	STD_LOGIC;
         pixel_x	:	out	std_logic_vector(9 downto 0);
         pixel_y	:	out	std_logic_vector(9 downto 0));
end component;

-- signals
signal clk : std_logic := '0';
signal V_sync	: STD_LOGIC := '0';
signal H_sync	: STD_LOGIC := '0';
signal video_on: STD_LOGIC := '0';
signal pixel_x	: std_logic_vector(9 downto 0) := "0000000000";
signal pixel_y	 :std_logic_vector(9 downto 0) := "0000000000";

-- time
constant clk_period : time := 20ns;

BEGIN

uut : VGA PORT MAP(
	clk => clk,
    V_sync => V_sync,
    H_sync => H_sync,
    video_on => video_on,
    pixel_x => pixel_x,
    pixel_y => pixel_y);
    
-- clock process
clk_proc : process
begin
	clk <= not(clk);
    wait for clk_period/2;
end process clk_proc;


-- stimulus process, not entirely needed as H sync and V sync just depend on clock
stim_proc : process
begin
	wait for clk_period*2; 
    
    wait;
    
 end process stim_proc;
 
 end testbench;
