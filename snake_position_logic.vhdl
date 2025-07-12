library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- Snake positioning datapath
-- Trym Loekkeberg
-- CS56/ENGS31 Final Project

entity snakeposition is
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

end entity;

architecture behavior of snakeposition is

    -- signals
    signal h_addr : integer := 1; -- address for the head of the snake
    signal t_addr : integer := 0; -- address for the tail of the snake
    signal headpos_x : unsigned(5 downto 0) := "000000"; -- x position for the head of the snake
    signal headpos_y : unsigned(5 downto 0) := "000000"; -- y position for the head of the snake
    signal secondcounter : integer := 0; -- to count until we want the snake to grow
    signal snake_grow : std_logic := '0'; -- control signal for when snake should grow 
    signal temp_x, temp_y : unsigned(5 downto 0) := "011001";
    signal enable : std_logic := '0';
    signal count, snakecount : integer := 0;
    signal speed : integer := 20000000; --for synthesis 
   --signal speed : integer := 10; --for simulation
    -- regfiles
    type regfile is array(0 to 39) of std_logic_vector(5 downto 0);
    signal xpos, ypos : regfile := (others => (others => '0')); -- regfiles for x and y coordinates of the snake

BEGIN

    -- sync proc
    sync_proc : process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset_en='1') then
                newhead_x <= "000000"; -- headpos_x 
                newhead_y <= "000000"; -- headpos_y
                headpos_x <= "000000"; -- something here
                headpos_y <= "000000";
                oldtail_x <= "000101";
                oldtail_y <= "001001";
                xpos <= (others => (others => '0'));
                ypos <= (others => (others => '0'));
                h_addr <= 1;
                t_addr <= 0;
                speed <= 20000000; --for synthesis
                --speed <= 10; --for simulation
                snakecount <= 0;
            else
                if (write_en='1') then
                    if (enable='1') then

                        oldtail_x <= xpos(t_addr);
                        oldtail_y <= ypos(t_addr);

                        newhead_x <= std_logic_vector(headpos_x);
                        newhead_y <= std_logic_vector(headpos_y);

                        -- write in the new headpos
                        xpos(h_addr) <= std_logic_vector(headpos_x);
                        ypos(h_addr) <= std_logic_vector(headpos_y);
                        -- update the new head coordinates for the output
                        if (snake_grow='1') then
                            t_addr <= t_addr; -- if snake is growing, do not increment the tail pointer
                            snake_grow <= '0';
                            if (h_addr = 39) then
                                h_addr <= 0;
                            else
                                h_addr <= h_addr + 1;
                            end if;
                        elsif (t_addr = 39) then  -- if we are at the end of memory, wrap around
                            t_addr <= 0;
                            h_addr <= h_addr + 1;
                        elsif (h_addr = 39) then -- if we are at the end of memory, wrap around
                            h_addr <= 0;
                            t_addr <= t_addr + 1;
                        else -- else just increment both pointers to keep the snake moving
                            h_addr <= h_addr + 1;
                            t_addr <= t_addr + 1;
                        end if;

                        -- set head position based on button press
                        if (up_en='1') then
                            temp_x <=  headpos_x;
                            temp_y <= headpos_y;
                            headpos_x <= headpos_x;
                            headpos_y <= headpos_y - 1;
                        elsif (down_en='1') then
                            temp_x <=  headpos_x;
                            temp_y <= headpos_y;
                            headpos_x <= headpos_x;
                            headpos_y <= headpos_y + 1;
                        elsif (right_en='1') then
                            temp_x <=  headpos_x;
                            temp_y <= headpos_y;
                            headpos_x <= headpos_x + 1;
                            headpos_y <= headpos_y;
                        elsif (left_en='1') then
                            temp_x <=  headpos_x;
                            temp_y <= headpos_y;
                            headpos_x <= headpos_x - 1;
                            headpos_y <= headpos_y;
                        else
                            headpos_x <= headpos_x;
                            headpos_y <= headpos_y;
                            temp_x <=  temp_x;
                            temp_y <= temp_y;
                        end if;
                    end if;
                else
                    h_addr <= h_addr;
                    t_addr <= t_addr;

                end if;
                -- grows snake
                if (size_en='1') then
                    snake_grow <= '1';
                    snakecount <= snakecount + 1;
                end if;

                -- snake count 
                if (snakecount = 4) then
                    speed <= speed - 2500000; --for synthesis 
                    --speed <= speed - 1; --for simulation
                    snakecount <= 0;
                    count <= 0;
                end if;

                -- counter to enable movement 
                count <= count + 1;
                if (count = speed) then -- 25 000 000/5 --15000000
                    enable <= '1';
                    count <= 0;
                else
                    enable <= '0';
                end if;
            end if;

            translator_en <= enable;

        end if;

    end process sync_proc;


    -- async proc
    async_proc : process(up_en, down_en, right_en, left_en, headpos_x, headpos_y)
    begin
        -- check if snake is out of bounds
        if (headpos_x > 19 or headpos_x < 0) then
            lose_s <= '1';
        elsif (headpos_y > 14 or headpos_y < 0) then
            lose_s <= '1';
        else
            lose_s <= '0';
        end if;

        -- check is snake is max length 
        if (h_addr = t_addr - 1) then
            win_s <= '1';
        else
            win_s <= '0';
        end if;
    end process async_proc;

end behavior;
