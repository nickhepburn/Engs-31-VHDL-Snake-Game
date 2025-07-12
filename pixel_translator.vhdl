library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY translator IS
    PORT ( 	clk		:	in	STD_LOGIC; --100 MHz clock
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
end translator;


architecture behavior of translator is

    signal px_int : integer := 0;
    signal py_int : integer := 0;

    type regfile_type is array(0 to 19, 0 to 14) of std_logic_vector(5 downto 0); -- 20x15
    signal regfile : regfile_type := (others => (others => "000000"));


begin

    --Process: Updates the game board array and checks for apple, snake conditions
    reg_proc : process(clk)
    begin
        if rising_edge(clk) then
            -- if new head and old tail have been written and the spot being written to is already green (has snake) then
            -- the snake has hit itself so lose signal goes high
            if datapath_en = '1' and
 not (newhead_x = "000000" and newhead_y = "000000") and
 regfile(to_integer(unsigned(newhead_x)),to_integer(unsigned(newhead_y))) = "000001" then
                lose_signal <= '1';
            else
                lose_signal <= '0';
            end if;

            -- when data has been written but the apple is under the snake then generate a new apple
            if datapath_en = '1' and regfile(to_integer(unsigned(apple_x)),to_integer(unsigned(apple_y))) = "000001" then
                apple_enable <= '1';
            else
                apple_enable <= '0';
            end if;


            -- when new head, old tail data has been written and the spot in game board array it writing to is a 2 
            -- then the snake has eaten the apple so we need new apple and increase the snake size
            if datapath_en = '1' and regfile(to_integer(unsigned(newhead_x)),to_integer(unsigned(newhead_y))) = "000010" then
                regfile(to_integer(unsigned(newhead_x)),to_integer(unsigned(newhead_y))) <= "000001";
                size_enable <= '1'; -- signal to increase snake size
                apple_enable <= '1'; -- signal to get new apple
            else
                size_enable <= '0';
                apple_enable <= '0';
            end if;


            if reset = '1' then
                regfile <= (others => (others => "000000")); -- reset game board 
            elsif write_en = '1' then
                regfile(to_integer(unsigned(newhead_x)),to_integer(unsigned(newhead_y))) <= "000001"; -- mark new head in game board
                regfile(to_integer(unsigned(oldtail_x)),to_integer(unsigned(oldtail_y))) <= "000000"; -- mark old tail as no longer in snake
                if datapath_en = '1' and regfile(to_integer(unsigned(apple_x)),to_integer(unsigned(apple_y))) /= "000001" then
                    -- only write new apple if the snake is not there
                    regfile(to_integer(unsigned(apple_x)),to_integer(unsigned(apple_y))) <= "000010";
                end if;
            end if;
        end if;
    end process reg_proc;

    clk_proc : process(clk)
    begin

        if rising_edge(clk) then
            -- make sure pixel_x and pixel_y are within confines of game board due to potential division issues
            if to_integer(unsigned(pixel_y(9 downto 5))) > 14 then
                py_int <= 14;
            else
                py_int <= to_integer(unsigned(pixel_y(9 downto 5)));
            end if;
            if to_integer(unsigned(pixel_x(9 downto 5))) > 19 then
                px_int <= 19;
            else
                px_int <= to_integer(unsigned(pixel_x(9 downto 5)));
            end if;

            -- set rgb to green if a 1 so snake there
            if regfile(px_int, py_int) = "000001" then
                rgb <= "000011110000";
            else
                rgb <= "000000000000";
            end if;
            -- set rgb to red if a 2 so apple is there
            if regfile(px_int, py_int) = "000010" then
                rgb <= "111100000000";
            end if;
        end if;
    end process clk_proc;


end behavior;
