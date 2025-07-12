library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity apple_gen_tb is
end apple_gen_tb;

architecture testbench of apple_gen_tb is

component apple_generator is
port(  
    clk : in std_logic;
    enable_translator : in std_logic;
    enable_fsm : in std_logic;
    apple_x : out std_logic_vector(5 downto 0);
    apple_y : out std_logic_vector(5 downto 0));    
end component;


-- signals 
signal clk : std_logic := '0';
signal enable_translator : std_logic := '0';
signal enable_fsm : std_logic := '0';
signal apple_x : std_logic_vector(5 downto 0) := "001101";
signal apple_y : std_logic_vector(5 downto 0) := "000011";

constant clk_period : time := 10ns;


begin

uut : apple_generator port map(
    clk => clk,
    enable_fsm => enable_fsm, 
    enable_translator => enable_translator,
    apple_x => apple_x,
    apple_y => apple_y);
    
    
clk_proc : process
begin 
    clk <= not(clk);
    wait for clk_period/2;
end process clk_proc;

stim_proc : process
begin
    wait for clk_period*2;
    
    enable_fsm <= '1'; --add initial apple at start
    wait for clk_period;
    enable_fsm <= '0';
    
    wait for clk_period*5;
    
    enable_translator <= '1'; --add apple after one has been eaten
    wait for clk_period;
    enable_translator <= '0';
    
    wait for clk_period*10; 
    enable_translator <= '1'; --add another from Pixel Translator
    wait for clk_period;
    enable_translator <= '0';
    
    wait;
end process stim_proc;
    
end testbench;


