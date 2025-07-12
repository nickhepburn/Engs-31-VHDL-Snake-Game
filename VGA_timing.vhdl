library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY VGA IS
    PORT ( 	clk		:	in	STD_LOGIC; --100 MHz clock
         V_sync	: 	out	STD_LOGIC;
         H_sync	: 	out	STD_LOGIC;
         video_on:	out	STD_LOGIC;
         pixel_x	:	out	std_logic_vector(9 downto 0);
         pixel_y	:	out	std_logic_vector(9 downto 0));
end VGA;


architecture behavior of VGA is

    signal H_video_on : STD_LOGIC := '0';
    signal V_video_on : STD_LOGIC := '0';
    signal PCLK : std_logic := '0';
    signal PCLK_last : std_logic := '0';
    constant PCLK_count : integer := 4;
    signal PCLK_counter : integer := 0;
    signal H_counter : unsigned(9 downto 0) := "0000000000";
    signal V_counter : unsigned(9 downto 0) := "0000000000";
    signal H_sync_sig : std_logic := '0';
    signal H_sync_last : std_logic := '0';

    --VGA Constants (taken directly from VGA Class Notes)
    constant left_border : integer := 48;
    constant h_display : integer := 640;
    constant right_border : integer := 16;
    constant h_retrace : integer := 96;
    constant HSCAN : integer := left_border + h_display + right_border + h_retrace - 1; --number of PCLKs in an H_sync period
    constant top_border : integer := 29;
    constant v_display : integer := 480;
    constant bottom_border : integer := 10;
    constant v_retrace : integer := 2;
    constant VSCAN : integer := top_border + v_display + bottom_border + v_retrace - 1; --number of H_syncs in an V_sync period
BEGIN

    --PCLK Generating Process
    --Process: Increments Pixel Clock until 4 to create 25 MHz clock, keeps track of last value of pixel clock
    PCLK_proc : process(clk)
    begin
        if rising_edge(clk) then
            PCLK_counter <= PCLK_counter + 1;
            if PCLK_counter = PCLK_count - 1 then
                PCLK <= '1';
                PCLK_last <= '0';
                PCLK_counter <= 0;
            else
                PCLK <= '0';
                PCLK_last <= '1';
            end if;
        end if;
    end process PCLK_proc;



    --H_sync generating process
    -- Process: Tracks rising edge of Pixel Clock
    Hsync_proc : process(clk)
    begin
        if rising_edge(clk) then
            if (PCLK = '1') AND (PCLK_last = '0') then --rising edge of Pixel Clock
                H_counter <= H_counter + 1;
                if H_counter = HSCAN then
                    H_counter <= "0000000000"; -- resets H_counter 
                end if;
                -- determines when h_video is high
                if H_counter < left_border - 1 then
                    h_video_on <= '0';
                elsif H_counter > left_border + h_display - 1 then
                    h_video_on <= '0';
                else
                    h_video_on <= '1';
                end if;
                --determines when H_sync is high
                if H_counter < left_border + h_display + right_border - 1 then
                    H_sync <= '1';
                    H_sync_sig <= '1';
                else
                    H_sync <= '0';
                    H_sync_sig <= '0';
                end if;
            end if;
        end if;
    end process Hsync_proc;

    --Process: tracks the last value of H_sync
    H_last : process(clk)
    begin
        if rising_edge(clk) then
            H_sync_last <= H_sync_sig;
        end if;
    end process;

    --V_sync generating process
    -- Process: updates V_sync on H_sync edge
    Vsync_proc : process(clk)
    begin
        if rising_edge(clk) then
            if H_sync_sig = '0' and H_sync_last = '1' then --rising edge of H_sync
                V_counter <= V_counter + 1;
                if V_counter = VSCAN then
                    V_counter <= "0000000000";
                end if;

            end if;
        end if;
    end process Vsync_proc;

    --Process: determines when V_sync goes high by taking into account retraces and porches
    v_sync_proc : process(V_counter)
    begin
        if V_counter < top_border - 1 then
            v_video_on <= '0';
        elsif V_counter > top_border + v_display - 1 then
            v_video_on <= '0';
        else
            v_video_on <= '1';
        end if;
        if V_counter < top_border + v_display + bottom_border - 1 then
            V_sync <= '1';
        else
            V_sync <= '0';
        end if;
    end process;

    video_on <= H_video_on AND V_video_on; -- video only on when H_video_on and V_video_on are both high

    --Process: determines the value of pixel x and pixel y by taking into account the borders of the dispaly
    pixel_output : process(H_video_on, V_video_on, V_counter, H_counter)
    begin
        if H_video_on = '1' AND V_video_on = '1' then
            pixel_x <= std_logic_vector(H_counter - left_border);
            pixel_y <= std_logic_vector(V_counter - top_border);
        else
            pixel_x <= "0000000000";
            pixel_y <= "0000000000";
        end if;
    end process pixel_output;


end behavior;

