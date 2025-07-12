library IEEE;
use IEEE.std_logic_1164.all;

entity controller is
    port(	clk			: in std_logic;
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
end controller;

architecture behavior of controller is

    -- SIGNAL DECLARATIONS
    type state_type is (idle, start, up, down, right, left, win, lose);
    signal CS, NS : state_type := idle;
    


BEGIN
    -- Update the current state
    stateUpdate : process(clk)
    begin
        if (rising_edge(clk)) then
            CS <= NS;
        end if;
    end process stateUpdate;

    -- next state logic
    --Process: next state during game play determined by button presses, lose game asserted if 
    --snake hits border or itself, game started if start button pressed
    nextstate_logic : process(CS, up_btn, down_btn, right_btn, left_btn, start_btn, win_game, lose_game)
    begin
        -- default
        NS <= CS;

        case CS is
            -- after start button pressed game begins playing
            when idle =>
                if (start_btn='1') then
                    NS <= start;
                end if;
            -- snake moves right initially
            when start =>
                NS <= right;
            --snake can old move horizontally when going up
            when up =>
                if (left_btn='1') then
                    NS <= left;
                elsif (right_btn='1') then
                    NS <= right;
                elsif (lose_game='1' or lose_signal_translator = '1') then
                    NS <= lose;
                elsif (win_game='1') then
                    NS <= win;
                end if;
            --game can only move horizontally when going down
            when down =>
                if (left_btn='1') then
                    NS <= left;
                elsif (right_btn='1') then
                    NS <= right;
                elsif (lose_game='1' or lose_signal_translator = '1') then
                    NS <= lose;
                elsif (win_game='1') then
                    NS <= win;
                end if;
            --game can only move vertically when going left or right
            when right =>
                if (up_btn='1') then
                    NS <= up;
                elsif (down_btn='1') then
                    NS <= down;
                elsif (lose_game='1' or lose_signal_translator = '1') then
                    NS <= lose;
               elsif (win_game='1') then
                    NS <= win;
                end if;

            when left =>
                if (up_btn='1') then
                    NS <= up;
                elsif (down_btn='1') then
                    NS <= down;
                elsif (lose_game='1' or lose_signal_translator = '1') then
                    NS <= lose;
               elsif (win_game='1') then
                    NS <= win;
                end if;
            --win or lose brings game back to idle state
            when win =>
                NS <= idle;

            when lose =>
                NS <= idle;

            when others =>
                NS <= idle;

        end case;
    end process nextstate_logic;

    -- output logic
    output_logic : process(CS)
    begin
        -- defaults

        write_en <= '1';
        up_en <= '0';
        down_en <= '0';
        right_en <= '0';
        left_en <= '0';
        reset_en <= '0';
        enable_apple <= '0';

        case CS is
            --in idle write_en low so no new head or tail written to game board
            when idle =>
                
                write_en <= '0';
 
            when start =>
                
                reset_en <= '1'; -- reset game board and snake head, tail
                enable_apple <= '1'; -- creates an initial apple

            when up =>
                
                up_en <= '1';

            when down =>
                
                down_en <= '1';

            when right =>
                
                right_en <= '1';

            when left =>
                
                left_en <= '1';

            when win =>
                
                write_en <= '0'; -- stops writing head and tail

            when lose =>
                
                write_en <= '0'; -- stops writing head and tail
        end case;
    end process output_logic;


end behavior;

