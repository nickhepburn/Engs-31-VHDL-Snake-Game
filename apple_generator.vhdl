library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity apple_generator is
    port(
        clk : in std_logic;
        enable_translator : in std_logic;
        enable_fsm : in std_logic;
        apple_x : out std_logic_vector(5 downto 0);
        apple_y : out std_logic_vector(5 downto 0));
end apple_generator;

architecture Behavioral of apple_generator is

    signal xcount : unsigned(5 downto 0) := "001010";
    signal ycount : unsigned(5 downto 0) := "000011";
   
    signal int_apple_x : std_logic_vector(5 downto 0) := "001010"; --position of starting apple
    signal int_apple_y : std_logic_vector(5 downto 0) := "000011"; --position of starting apple
    
begin

    -- clocked process 
    clk_proc : process(clk)
    begin
        if (rising_edge(clk)) then
            -- get x and y from counter and make the coordinates of a new apple when 
            -- needed based on enable signals
            if (enable_translator='1' or enable_fsm='1') then
                int_apple_x <= std_logic_vector(xcount);
                int_apple_y <= std_logic_vector(ycount);
            else
                int_apple_x <= int_apple_x;
                int_apple_y <= int_apple_y;
            end if;

            -- count    
            xcount <= xcount + 1;
            ycount <= ycount + 1;

            if (xcount = 19) then
                xcount <= "000000";
            end if;

            if (ycount = 14) then
                ycount <= "000000";
            end if;
        end if;
    end process clk_proc;

    apple_x <= int_apple_x;
    apple_y <= int_apple_y;

end Behavioral;

