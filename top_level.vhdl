library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity top_level_shell is
    Port (
        clk_ext_port		: in std_logic;		-- mapped to external IO device (100 MHz Clock)	
        right_ext_port      : in std_logic;     -- right button signal from FPGA
        left_ext_port       : in std_logic;     -- left button signal from FPGA
        down_ext_port       : in std_logic;     -- down button signal from FPGA
        up_ext_port         : in std_logic;     -- up button signal from FPGA
        start_ext_port      : in std_logic;		-- center button signal from FPGA	
        H_sync_port			: out std_logic;    -- horizontal VGA timing
        V_sync_port			: out std_logic;    -- vertical VGA timing
        video_on_port       : out std_logic;    -- controls video on, off on VGA 
        rgb_port			: out std_logic_vector(11 downto 0));
end top_level_shell;

--=============================================================================
--Architecture Type:
--=============================================================================

architecture behavioral_architecture of top_level_shell is

    --=============================================================================
    --Sub-Component Declarations:
    --=============================================================================
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --VGA Timing
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    component VGA is
        Port (
            clk		:	in	STD_LOGIC; --100 MHz clock
            V_sync	: 	out	STD_LOGIC; --vertical timing for VGA
            H_sync	: 	out	STD_LOGIC; --horizontal timing for VGA
            video_on:	out	STD_LOGIC; --determines video on or off for VGA
            pixel_x	:	out	std_logic_vector(9 downto 0); --VGA x pixel
            pixel_y	:	out	std_logic_vector(9 downto 0)); --VGA y pixel
    end component;

    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Color Test File
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    component translator is
        Port (
            clk		:	in	STD_LOGIC; --100 MHz clock
            write_en: in std_logic;
            newhead_x :   in  std_logic_vector(5 downto 0);  --game board x component of the new head
            newhead_y :   in std_logic_vector(5 downto 0);   -- game board y component of the new head
            oldtail_x :   in  std_logic_vector(5 downto 0);  -- game board x component of the old tail
            oldtail_y :   in std_logic_vector(5 downto 0);   --game board y component of the old tail
            pixel_x	:	in std_logic_vector(9 downto 0);    -- VGA pixel x
            pixel_y	:	in std_logic_vector(9 downto 0);    -- VGA pixel y
            datapath_en:in std_logic;                       -- enable signal that goes high when tail and head updated
            reset    : in std_logic;                        -- signal that reset the game board
            apple_x :   in std_logic_vector(5 downto 0);    -- x component of the apple location
            apple_y :   in std_logic_vector(5 downto 0);    -- y component of the apple location
            lose_signal : out std_logic;                    -- lose signal for when snake runs into itself
            apple_enable : out std_logic;                   -- enable signal that tells apple generator to create new apple
            size_enable : out std_logic;                    -- enable signal that goes high when apple is eaten, need to update size
            rgb		:   out std_logic_vector(11 downto 0)); -- 12-bit RGB value to be displayed at given VGA x and y
    end component;

    component snakeposition is
        port(	clk 	: in std_logic; -- 100 MHz clock
             up_en   : in std_logic; -- tracks up button press
             down_en : in std_logic; -- tracks down button press
             right_en: in std_logic;  -- tracks right button press
             left_en : in std_logic;  -- tracks left button press
             size_en : in std_logic;  -- goes high if need to increase size of snake
             reset_en: in std_logic;  -- resets snake if high
             write_en: in std_logic;  -- passes new head and old tail if high
             lose_s  : out std_logic; -- goes high if snake hits border or itself
             win_s   : out std_logic; -- goes high if snake fills entire display
             translator_en: out std_logic; -- goes high when new head and old tail are written
             newhead_x : out std_logic_vector; -- x coordinate for updated head position 
             newhead_y : out std_logic_vector; -- y coordinate for updated head position 
             oldtail_x : out std_logic_vector; -- x coordinate for the previous tail position 
             oldtail_y : out std_logic_vector);
    end component;

    component controller is
        port(	clk			: in std_logic; -- 100 MHz clock
             up_btn		: in std_logic; -- tracks up button press
             down_btn	: in std_logic; -- tracks down button press
             right_btn	: in std_logic; -- tracks right button press
             left_btn 	: in std_logic; -- tracks left button press
             start_btn	: in std_logic;  -- tracks start (center) button press
             win_game	: in std_logic;  -- win game signal
             lose_game	: in std_logic;  -- goes high if snake hits border
             lose_signal_translator : in std_logic; --goes high if snake hits itself
             write_en	: out std_logic; --goes high when new head and old tail being written
             up_en		: out std_logic; -- up signal to snake position
             down_en		: out std_logic; -- down signal to snake position
             right_en	: out std_logic; -- right signal to snake position
             left_en		: out std_logic; -- left signal to snake position
             enable_apple    : out std_logic; -- goes high when apple needs to be generated
             reset_en    : out std_logic);  -- goes high when game board needs to be resest
    end component;

    component apple_generator is
        port(
            clk : in std_logic; --100 MHz clock
            enable_translator : in std_logic; -- signal that goes high when apple needs to be generated (from Pixel Translator)
            enable_fsm : in std_logic; -- signal that goes high when apple needs to be generated (from FSM)
            apple_x : out std_logic_vector(5 downto 0); -- x component of apple location
            apple_y : out std_logic_vector(5 downto 0)); -- y component of apple location
    end component;

    component button_interface is
        Port( clk_port            : in  std_logic; -- 100 MHz clock
             button_port         : in  std_logic; -- raw button signal
             button_db_port      : out std_logic; -- debounced button signal
             button_mp_port      : out std_logic); -- monopulsed button signal
    end component;

    --=============================================================================
    --Signal Declarations: 
    --=============================================================================

    signal x : std_logic_vector(9 downto 0) := "0000000000"; -- VGA pixel x signal
    signal y : std_logic_vector(9 downto 0) := "0000000000"; -- VGA pixel y signal
    signal nhx : std_logic_vector(5 downto 0) := "000000"; -- new head x signal
    signal nhy : std_logic_vector(5 downto 0) := "000000"; -- new head y signal
    signal otx : std_logic_vector(5 downto 0) := "000000"; -- old tail x signal
    signal oty : std_logic_vector(5 downto 0) := "000000"; -- old tail y signal
    signal video : std_logic := '1'; -- video enable signal

    signal wingame : std_logic := '0';
    signal losegame : std_logic := '0';
    signal losetrans : std_logic := '0';

    -- controller 
    signal right_signal : std_logic := '0';
    signal left_signal : std_logic := '0';
    signal down_signal : std_logic := '0';
    signal up_signal   : std_logic := '0';
    signal start_signal : std_logic := '0';
    signal write_en_signal : std_logic := '0';

    signal data_en : std_logic := '0';

    -- debounced and monopulsed buttons 
    signal up : std_logic := '0';
    signal down : std_logic := '0';
    signal right : std_logic := '0';
    signal left : std_logic := '0';
    signal start : std_logic := '0';
    signal reset_signal : std_logic := '0';

    --apple signal
    signal apple_x_signal : std_logic_vector(5 downto 0) := "000000";
    signal apple_y_signal : std_logic_vector(5 downto 0) := "000000";
    signal apple_en_signal : std_logic := '0';
    signal apple_en_fsm_signal : std_logic := '0';
    signal size_en_signal : std_logic := '0';

    --=============================================================================
    --Port Mapping (wiring the component blocks together): 
    --=============================================================================
begin

    -- VGA timing controller
    timing: VGA port map(
            pixel_x => x,
            pixel_y => y,
            clk  => clk_ext_port,
            V_sync => V_sync_port,
            video_on => video_on_port,
            H_sync => H_sync_port);
    -- Pixel Translator component
    test_color: translator port map(
            clk => clk_ext_port,
            newhead_x => nhx,
            newhead_y => nhy,
            write_en => write_en_signal,
            oldtail_x => otx,
            oldtail_y =>  oty,
            reset => reset_signal,
            pixel_x => x,
            datapath_en => data_en,
            pixel_y => y,
            apple_x => apple_x_signal,
            apple_y => apple_y_signal,
            apple_enable => apple_en_signal,
            size_enable => size_en_signal,
            lose_signal => losetrans,
            rgb => rgb_port);
    -- snake position logic component
    snake_position : snakeposition port map (
            clk => clk_ext_port,
            up_en => up_signal,
            down_en => down_signal,
            right_en => right_signal,
            left_en => left_signal,
            reset_en => reset_signal,
            newhead_x => nhx,
            write_en => write_en_signal,
            size_en => size_en_signal,
            lose_s => losegame,
            win_s => wingame,
            translator_en => data_en,
            newhead_y => nhy,
            oldtail_x => otx,
            oldtail_y => oty);

    -- the state machine for the snake movement
    FSM : controller port map(
            clk => clk_ext_port,
            up_btn => up,
            down_btn => down,
            right_btn => right,
            left_btn => left,
            start_btn => start,
            win_game => wingame,
            lose_game => losegame,
            write_en => write_en_signal,
            reset_en => reset_signal,
            up_en => up_signal,
            down_en => down_signal,
            right_en => right_signal,
            lose_signal_translator => losetrans,
            enable_apple => apple_en_fsm_signal,
            left_en => left_signal);
    --creates new apples in random locations on screen
    applegen : apple_generator port map(
            clk => clk_ext_port,
            apple_x => apple_x_signal,
            apple_y => apple_y_signal,
            enable_translator => apple_en_signal,
            enable_fsm => apple_en_fsm_signal);

    --monopulses the button inputs
    right_monopulse: button_interface port map(
            clk_port            =>     clk_ext_port,
            button_port         =>     right_ext_port,
            button_db_port      =>     OPEN,
            button_mp_port      =>     right);
    left_monopulse: button_interface port map(
            clk_port            =>     clk_ext_port,
            button_port         =>     left_ext_port,
            button_db_port      =>     OPEN,
            button_mp_port      =>     left);
    up_monopulse: button_interface port map(
            clk_port            =>     clk_ext_port,
            button_port         =>     up_ext_port,
            button_db_port      =>     OPEN,
            button_mp_port      =>     up);
    down_monopulse: button_interface port map(
            clk_port            =>     clk_ext_port,
            button_port         =>     down_ext_port,
            button_db_port      =>     OPEN,
            button_mp_port      =>     down);

    start_monopulse: button_interface port map(
            clk_port            =>      clk_ext_port,
            button_port         =>      start_ext_port,
            button_db_port      =>      OPEN,
            button_mp_port      =>      start);

end behavioral_architecture;
