LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY Pong IS
    PORT (
        clk : IN STD_LOGIC := '0';
        hsync, vsync : OUT STD_LOGIC;
        red, green, blue : OUT
        STD_LOGIC_VECTOR(3 DOWNTO 0);

        -- Controllers
        -- P1
        miso : IN STD_LOGIC; --SPI master in, slave out
        mosi : OUT STD_LOGIC; --SPI master out, slave in
        sclk : BUFFER STD_LOGIC; --SPI clock
        cs_n : OUT STD_LOGIC; --pmod chip select
        -- P2
        miso2 : IN STD_LOGIC; --SPI master in, slave out
        mosi2 : OUT STD_LOGIC; --SPI master out, slave in
        sclk2 : BUFFER STD_LOGIC; --SPI clock
        cs_n2 : OUT STD_LOGIC; --pmod chip select

        -- Vibrator
        vib_1 : BUFFER STD_LOGIC := '0';
        vib_2 : BUFFER STD_LOGIC := '0';

        -- Amp
        -- data_out : OUT STD_LOGIC;
        -- mck : OUT STD_LOGIC;
        -- lrck : OUT STD_LOGIC;
        -- sck : OUT STD_LOGIC;

        -- On-board
        led : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        switch : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        btnu : IN STD_LOGIC;
        btnd : IN STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btnc : IN STD_LOGIC

    );
END Pong;

ARCHITECTURE Behavioral OF Pong IS

    -- Components
    COMPONENT clock_divider IS
        GENERIC (N : INTEGER);
        PORT (
            CLK_IN : IN STD_LOGIC;
            CLK_OUT : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT vga IS
        PORT (
            clk, clk_ball, clk_item : IN STD_LOGIC;
            sys_clk : IN STD_LOGIC;
            hsync, vsync : OUT STD_LOGIC;
            pseudo_rand : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            BALL_X_BASESTEP : IN INTEGER;
            BALL_Y_BASESTEP : IN INTEGER;
            ILLUSION_BALL_X_BASESTEP : IN INTEGER;
            ILLUSION_BALL_Y_BASESTEP : IN INTEGER;
            BALL_SIZE : IN INTEGER;
            strong_hit_multiplier : IN INTEGER;
            weak_hit_multiplier : IN INTEGER;
            P1_PADDLE_DX : INOUT INTEGER;
            P2_PADDLE_DX : INOUT INTEGER;
            P1_PADDLE_DY : INOUT INTEGER;
            P2_PADDLE_DY : INOUT INTEGER;
            PADDLE_SIZE : IN INTEGER;
            P1_PADDLE_LENGTH : INOUT INTEGER;
            P2_PADDLE_LENGTH : INOUT INTEGER;
            player1_control_signal : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            player2_control_signal : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            player1_score : IN INTEGER;
            player2_score : IN INTEGER;
            ai_state : INOUT INTEGER;
            is_end : IN STD_LOGIC;
            game_begin : IN STD_LOGIC;
            game_reset : IN STD_LOGIC;
            is_frenzy : IN STD_LOGIC;
            is_ai : IN STD_LOGIC;
            rendering_ball : OUT STD_LOGIC;
            rendering_illusion_ball : OUT STD_LOGIC;
            rendering_board_up : OUT STD_LOGIC;
            rendering_board_down : OUT STD_LOGIC;
            rendering_board_mid : OUT STD_LOGIC;
            rendering_board_left : OUT STD_LOGIC;
            rendering_board_right : OUT STD_LOGIC;
            rendering_p1_scoreboard : OUT STD_LOGIC;
            rendering_p2_scoreboard : OUT STD_LOGIC;
            rendering_p1_paddle : OUT STD_LOGIC;
            rendering_p2_paddle : OUT STD_LOGIC;
            rendering_winner : OUT STD_LOGIC;
            rendering_frenzy : OUT STD_LOGIC;
            rendering_p1_item : OUT STD_LOGIC;
            rendering_p2_item : OUT STD_LOGIC;
            ball_startx_offset : IN INTEGER;
            ball_starty_offset : IN INTEGER;
            p1_item_trigger : INOUT INTEGER;
            p2_item_trigger : INOUT INTEGER;
            p1_item_ready : INOUT STD_LOGIC;
            p2_item_ready : INOUT STD_LOGIC;
            is_long_p1 : INOUT STD_LOGIC;
            is_long_p2 : INOUT STD_LOGIC;
            is_speed_p1 : INOUT STD_LOGIC;
            is_speed_p2 : INOUT STD_LOGIC;
            is_poison_p1 : INOUT STD_LOGIC;
            is_poison_p2 : INOUT STD_LOGIC;
            is_left_miss : INOUT STD_LOGIC;
            is_right_miss : INOUT STD_LOGIC;
            is_strong : OUT STD_LOGIC;
            is_weak : OUT STD_LOGIC;
            is_winner : IN STD_LOGIC;
            led : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            vib_1 : BUFFER STD_LOGIC;
            vib_2 : BUFFER STD_LOGIC
        
        );
    END COMPONENT;

    COMPONENT joystick IS
        GENERIC (
            clk_freq : INTEGER := 50); --system clock frequency in MHz
        PORT (
            clk : IN STD_LOGIC; --system clock
            miso : IN STD_LOGIC; --SPI master in, slave out
            mosi : OUT STD_LOGIC; --SPI master out, slave in
            sclk : BUFFER STD_LOGIC; --SPI clock
            cs_n : OUT STD_LOGIC; --pmod chip select
            direction : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            center_button : OUT STD_LOGIC
        );
    END COMPONENT joystick;

    -- COMPONENT I2S_pmod
    --     PORT (
    --         clock : IN STD_LOGIC;
    --         reset : IN STD_LOGIC;
    --         data_r : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    --         data_l : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    --         data_out : OUT STD_LOGIC;
    --         MCK : OUT STD_LOGIC;
    --         LRCK : OUT STD_LOGIC;
    --         SCK : OUT STD_LOGIC
    --     );
    -- END COMPONENT;

    -- Signals
    SIGNAL clk1Hz, clk2Hz, clk10Hz, clk60Hz, clk50MHz : STD_LOGIC;
    SIGNAL in_hsync, in_vsync : STD_LOGIC;

    SIGNAL rendering_ball : STD_LOGIC;
    SIGNAL rendering_illusion_ball : STD_LOGIC;
    SIGNAL rendering_board_up : STD_LOGIC;
    SIGNAL rendering_board_down : STD_LOGIC;
    SIGNAL rendering_board_mid : STD_LOGIC;
    SIGNAL rendering_board_left : STD_LOGIC;
    SIGNAL rendering_board_right : STD_LOGIC;
    SIGNAL rendering_p1_scoreboard : STD_LOGIC;
    SIGNAL rendering_p2_scoreboard : STD_LOGIC;
    SIGNAL rendering_p1_paddle : STD_LOGIC;
    SIGNAL rendering_p2_paddle : STD_LOGIC;
    SIGNAL rendering_winner : STD_LOGIC;
    SIGNAL rendering_frenzy : STD_LOGIC;
    SIGNAL rendering_p1_item : STD_LOGIC;
    SIGNAL rendering_p2_item : STD_LOGIC;

    SIGNAL player1_score : INTEGER := 0;
    SIGNAL player2_score : INTEGER := 0;
    SIGNAL player1_center_button : STD_LOGIC := '0';
    SIGNAL player2_center_button : STD_LOGIC := '0';
    SIGNAL player1_control_signal : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
    SIGNAL player2_control_signal : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";

    -- States
    SIGNAL state : INTEGER := 0;
    SIGNAL is_end : STD_LOGIC := '0';
    SIGNAL is_frenzy : STD_LOGIC := '0';
    SIGNAL is_ai : STD_LOGIC := '0';
    SIGNAL is_left_miss : STD_LOGIC := '0';
    SIGNAL is_right_miss : STD_LOGIC := '0';
    SIGNAL p1_score_trigger : STD_LOGIC := '0';
    SIGNAL p2_score_trigger : STD_LOGIC := '0';
    SIGNAL game_begin : STD_LOGIC := '0';
    SIGNAL game_reset : STD_LOGIC := '0';
    SIGNAL is_strong : STD_LOGIC := '0';
    SIGNAL is_weak : STD_LOGIC := '0';
    SIGNAL is_winner : STD_LOGIC := '0';
    SIGNAL ball_startx_offset : INTEGER;
    SIGNAL ball_starty_offset : INTEGER;
    SIGNAL pseudo_rand : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cycle_count : INTEGER := 0;
    SIGNAL ai_state : INTEGER := 1;

    -- Amp Data
    -- SIGNAL amp_trigger : STD_LOGIC := '0';
    -- SIGNAL amp_activate : STD_LOGIC := '0';
    -- SIGNAL amp_count : INTEGER := 0;
    -- SIGNAL data_in_l : STD_LOGIC_VECTOR (15 DOWNTO 0) := "0000000000000000";
    -- SIGNAL data_in_r : STD_LOGIC_VECTOR (15 DOWNTO 0) := "0000000000000000";

    -- Game Settings
    -- Ball
    CONSTANT BALL_X_BASESTEP : INTEGER := 5;
    CONSTANT BALL_Y_BASESTEP : INTEGER := 5;
    CONSTANT ILLUSION_BALL_X_BASESTEP : INTEGER := 5;
    CONSTANT ILLUSION_BALL_Y_BASESTEP : INTEGER := 5;
    CONSTANT BALL_SIZE : INTEGER := 20;
    CONSTANT strong_hit_multiplier : INTEGER := 4;
    CONSTANT weak_hit_multiplier : INTEGER := 2;
    -- Paddles
    CONSTANT PADDLE_SIZE : INTEGER := 10;
    SIGNAL P1_PADDLE_LENGTH : INTEGER := 60;
    SIGNAL P1_PADDLE_DX : INTEGER := 5;
    SIGNAL P1_PADDLE_DY : INTEGER := 5;
    SIGNAL P2_PADDLE_LENGTH : INTEGER := 60;
    SIGNAL P2_PADDLE_DX : INTEGER := 5;
    SIGNAL P2_PADDLE_DY : INTEGER := 5;

    -- Item
    SIGNAL p1_item_trigger : INTEGER := 0;
    SIGNAL p2_item_trigger : INTEGER := 0;
    SIGNAL p1_item_ready : STD_LOGIC := '0';
    SIGNAL p2_item_ready : STD_LOGIC := '0';
    SIGNAL is_long_p1 : STD_LOGIC := '0';
    SIGNAL is_long_p2 : STD_LOGIC := '0';
    SIGNAL is_speed_p1 : STD_LOGIC := '0';
    SIGNAL is_speed_p2 : STD_LOGIC := '0';
    SIGNAL is_poison_p1 : STD_LOGIC := '0';
    SIGNAL is_poison_p2 : STD_LOGIC := '0';

BEGIN
    -- generate clock
    u_clk50mhz : clock_divider GENERIC MAP(N => 1)
    PORT MAP(clk, clk50MHz);
    u_clk1hz : clock_divider GENERIC MAP(N => 50000000)
    PORT MAP(clk, clk1Hz);
    u_clk10hz : clock_divider GENERIC MAP(N => 5000000)
    PORT MAP(clk, clk10Hz);
    u_clk60hz : clock_divider GENERIC MAP(N => 833334)
    PORT MAP(clk, clk60Hz);

    -- Controller mapping
    player1 : joystick
    GENERIC MAP(clk_freq => 50)
    PORT MAP(
        clk => clk, miso => miso, mosi => mosi, sclk => sclk,
        cs_n => cs_n, direction => player1_control_signal,
        center_button => player1_center_button
    );

    player2 : joystick
    GENERIC MAP(clk_freq => 50)
    PORT MAP(
        clk => clk, miso => miso2, mosi => mosi2, sclk => sclk2,
        cs_n => cs_n2, direction => player2_control_signal,
        center_button => player2_center_button
    );

    -- VGA
    vga_unit : vga PORT MAP(
        clk50MHz, clk60Hz, clk1Hz,
        clk,
        in_hsync, in_vsync,
        pseudo_rand,
        BALL_X_BASESTEP,
        BALL_Y_BASESTEP,
        ILLUSION_BALL_X_BASESTEP,
        ILLUSION_BALL_Y_BASESTEP,
        BALL_SIZE,
        strong_hit_multiplier,
        weak_hit_multiplier,
        P1_PADDLE_DX,
        P2_PADDLE_DX,
        P1_PADDLE_DY,
        P2_PADDLE_DY,
        PADDLE_SIZE,
        P1_PADDLE_LENGTH,
        P2_PADDLE_LENGTH,
        player1_control_signal, player2_control_signal,
        player1_score, player2_score,
        ai_state,
        is_end,
        game_begin,
        game_reset,
        is_frenzy,
        is_ai,
        rendering_ball,
        rendering_illusion_ball,
        rendering_board_up,
        rendering_board_down,
        rendering_board_mid,
        rendering_board_left,
        rendering_board_right,
        rendering_p1_scoreboard,
        rendering_p2_scoreboard,
        rendering_p1_paddle,
        rendering_p2_paddle,
        rendering_winner,
        rendering_frenzy,
        rendering_p1_item,
        rendering_p2_item,
        ball_startx_offset,
        ball_starty_offset,
        p1_item_trigger,
        p2_item_trigger,
        p1_item_ready,
        p2_item_ready,
        is_long_p1,
        is_long_p2,
        is_speed_p1,
        is_speed_p2,
        is_poison_p1,
        is_poison_p2,
        is_left_miss,
        is_right_miss,
        is_strong,
        is_weak,
        is_winner,
        led,
        vib_1,
        vib_2
    );

    -- Amp
    -- uut : I2S_pmod PORT MAP(
    --     clock => clk,
    --     reset => amp_trigger,
    --     data_r => data_in_r,
    --     data_l => data_in_l,
    --     data_out => data_out,
    --     MCK => MCK,
    --     LRCK => LRCK,
    --     SCK => SCK
    -- );

    -- Start
    -- Rendering
    PROCESS (rendering_ball,
        rendering_illusion_ball,
        rendering_board_up,
        rendering_board_down,
        rendering_board_mid,
        rendering_board_left,
        rendering_p1_scoreboard,
        rendering_p2_scoreboard,
        rendering_winner,
        rendering_frenzy,
        rendering_p1_item,
        rendering_p2_item,
        is_long_p1,
        is_long_p2,
        is_speed_p1,
        is_speed_p2,
        is_poison_p1,
        is_poison_p2,
        is_ai,
        is_strong,
        is_weak
        )
    BEGIN
        IF rendering_ball = '1' THEN
            IF (is_strong = '1') THEN
                red <= "1111";
                green <= "0000";
                blue <= "0000";
            ELSIF (is_weak = '1') THEN
                red <= "0000";
                green <= "0000";
                blue <= "1111";
            ELSE
                red <= "1111";
                green <= "1111";
                blue <= "1111";
            END IF;
        ELSIF rendering_illusion_ball = '1' THEN
            red <= "1100";
            green <= "0000";
            blue <= "0000";
        ELSIF rendering_board_up = '1'
            OR rendering_board_down = '1'
            OR rendering_board_mid = '1'
            OR rendering_board_left = '1'
            OR rendering_board_right = '1'
            THEN
            red <= "1111";
            green <= "1111";
            blue <= "0000";
        ELSIF rendering_p1_paddle = '1'
            THEN
            IF (is_long_p1 = '1') THEN
                red <= "0000";
                green <= "1111";
                blue <= "0000";
            ELSIF (is_speed_p1 = '1') THEN
                red <= "1111";
                green <= "0000";
                blue <= "0000";
            ELSIF (is_poison_p1 = '1') THEN
                red <= "1111";
                green <= "0000";
                blue <= "1111";
            else
                red <= "0000";
                green <= "1111";
                blue <= "0000";
            END IF;
        ELSIF rendering_p2_paddle = '1'
            THEN
            IF (is_ai = '0')
                THEN
                IF (is_long_p2 = '1') THEN
                    red <= "0000";
                    green <= "1111";
                    blue <= "0000";
                ELSIF (is_speed_p2 = '1') THEN
                    red <= "1111";
                    green <= "0000";
                    blue <= "0000";
                ELSIF (is_poison_p2 = '1') THEN
                    red <= "1111";
                    green <= "0000";
                    blue <= "1111";
                else
                    red <= "0000";
                    green <= "1111";
                    blue <= "0000";
                END IF;
            ELSE
                -- Set paddle color to red if is VS AI mode
                CASE (ai_state) IS
                        -- Level 1
                    WHEN 1 =>
                        red <= "0000";
                        green <= "0000";
                        blue <= "1111";
                        -- Level 2
                    WHEN 2 =>
                        red <= "1111";
                        green <= "0000";
                        blue <= "1111";
                        -- Over Drive
                    WHEN 3 =>
                        red <= "1111";
                        green <= "0000";
                        blue <= "0000";
                        -- Fatigue
                    WHEN 4 =>
                        red <= "1111";
                        green <= "1111";
                        blue <= "0000";
                        -- Final State
                    WHEN 5 =>
                        red <= "0000";
                        green <= "1111";
                        blue <= "1111";
                    WHEN OTHERS =>
                        red <= "0000";
                        green <= "0000";
                        blue <= "0000";
                END CASE;
            END IF;
        ELSIF rendering_p1_scoreboard = '1'
            THEN
            IF (player1_score > 9)
                THEN
                red <= "1111";
                green <= "0000";
                blue <= "0000";
            ELSE
                red <= "1111";
                green <= "1111";
                blue <= "1111";
            END IF;
        ELSIF rendering_p2_scoreboard = '1'
            THEN
            IF (player2_score > 9)
                THEN
                red <= "1111";
                green <= "0000";
                blue <= "0000";
            ELSE
                red <= "1111";
                green <= "1111";
                blue <= "1111";
            END IF;
        ELSIF rendering_winner = '1'
            THEN
            red <= "0000";
            green <= "1111";
            blue <= "0000";
        ELSIF rendering_frenzy = '1'
            THEN
            red <= "0000";
            green <= "0000";
            blue <= "1111";
        ELSIF rendering_p1_item = '1'
            THEN
            red <= "1111";
            green <= "1111";
            blue <= "0000";
        ELSIF rendering_p2_item = '1'
            THEN
            red <= "1111";
            green <= "1111";
            blue <= "0000";
        ELSE
            red <= "0000";
            green <= "0000";
            blue <= "0000";
        END IF;
    END PROCESS;

    -- Score Handler
    PROCESS (clk10Hz, p1_score_trigger, p2_score_trigger, game_reset)
    BEGIN
        IF (rising_edge(clk10Hz)) THEN
            IF (p1_score_trigger = '1' OR btnl = '1') THEN
                player1_score <= player1_score + 1;
            ELSIF (p2_score_trigger = '1' OR btnr = '1') THEN
                player2_score <= player2_score + 1;
            ELSIF (game_reset = '1') THEN
                player1_score <= 0;
                player2_score <= 0;
            END IF;
        END IF;
    END PROCESS;

    -- State controller
    PROCESS (clk10Hz, is_left_miss, is_right_miss)
    BEGIN
        IF (rising_edge(clk10Hz))
            THEN
            CASE (state) IS
                -- Game initial state
                WHEN 0 =>
                    -- IF (btnu = '1') THEN
                    --     amp_activate <= not amp_activate;
                    -- END IF;
                    game_begin <= '0';
                    is_end <= '1';
                    is_winner <= '0';
                    --pmod_num <= "00000000";
                    game_reset <= '1';
                    is_ai <= switch(0);
                    is_frenzy <= switch(1);
                    -- Use for generating random number
                    cycle_count <= cycle_count + 1;
                    -- Either one of the player press their center button
                    IF (((player1_center_button = '1' OR player2_center_button = '1') AND is_ai = '0')
                        OR (player1_center_button = '1' AND is_ai = '1'))
                        THEN
                        state <= 1;
                    END IF;
                -- Pre-start state (Calculate the ball_start_offset)
                WHEN 1 =>
                    game_begin <= '1';
                    game_reset <= '0';
                    p1_score_trigger <= '0';
                    p2_score_trigger <= '0';
                    state <= 2;
                    is_end <= '0';
                    -- pmod_num(3 downto 0) <= STD_LOGIC_VECTOR(to_unsigned(shoot, 4));
                    -- to_integer(unsigned(pseudo_rand)) mod 8
                    CASE (to_integer(unsigned(pseudo_rand)) MOD 8) IS
                        -- 8 cases to decide 8 directions to start
                        -- Divide 8 cases in 360degree, skip 90, 180, 270, 360 degree
                        -- +x, -y
                        WHEN 0 =>
                            ball_startx_offset <= 0;
                            ball_starty_offset <= - (BALL_X_BASESTEP + BALL_Y_BASESTEP);
                        -- Default
                        WHEN 1 =>
                            ball_startx_offset <= 0;
                            ball_starty_offset <= 0;
                        -- -x, +y
                        WHEN 2 =>
                            ball_startx_offset <= - (BALL_X_BASESTEP + BALL_Y_BASESTEP);
                            ball_starty_offset <= 0;
                        -- -x, -y
                        WHEN 3 =>
                            ball_startx_offset <= - (BALL_X_BASESTEP + BALL_Y_BASESTEP);
                            ball_starty_offset <= - (BALL_X_BASESTEP + BALL_Y_BASESTEP);
                        WHEN OTHERS =>
                    END CASE;
                -- Game is running
                WHEN 2 =>
                    -- pmod_num(3 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(pseudo_rand)) mod 8, 4));

                    -- Press center button to reset
                    IF (btnc = '1')
                        THEN
                        is_end <= '1';
                        state <= 0;

                        -- If left miss
                    ELSIF (is_left_miss = '1')
                        THEN
                        is_end <= '1';
                        -- Right hand side score + 1
                        -- If reach 10, game set
                        IF (player2_score < 9) THEN
                            p2_score_trigger <= '1';
                            state <= 1;
                        ELSE
                            p2_score_trigger <= '1';
                            state <= 3;
                        END IF;
                        -- If right miss
                    ELSIF (is_right_miss = '1')
                        THEN
                        is_end <= '1';
                        data_in_r <= "1010101010101010";
                        -- Left hand side score + 1
                        -- If reach 10, game set
                        IF (player1_score < 9) THEN
                            p1_score_trigger <= '1';
                            state <= 1;
                        ELSE
                            p1_score_trigger <= '1';
                            state <= 3;
                        END IF;
                    END IF;
                -- Winner is out
                WHEN 3 =>
                    is_winner <= '1';
                    p1_score_trigger <= '0';
                    p2_score_trigger <= '0';
                    IF (((player1_center_button = '1' OR player2_center_button = '1') AND is_ai = '0')
                        OR (player1_center_button = '1' AND is_ai = '1'))
                        THEN
                        state <= 0;
                    END IF;

                WHEN OTHERS =>

            END CASE;
        END IF;
    END PROCESS;

    -- Generating a 32-bit random number
    PROCESS (clk10Hz)
        FUNCTION lfsr32(x : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        BEGIN
            RETURN x(30 DOWNTO 0) & (x(0) XNOR x(1) XNOR x(21) XNOR x(31));
        END FUNCTION;
    BEGIN
        IF (rising_edge(clk10Hz) AND game_begin = '1')THEN
            pseudo_rand <= STD_LOGIC_VECTOR(to_unsigned(cycle_count, 32));
            pseudo_rand <= lfsr32(pseudo_rand);
        END IF;
    END PROCESS;

    --Amp Process
    -- PROCESS (clk60Hz)
    -- BEGIN
    --     IF (rising_edge(clk60Hz)) THEN
    --         amp_trigger <= '1';
    --         data_in_l <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(data_in_l)) + 1, 16));
    --     END IF;
    -- END PROCESS;

    hsync <= in_hsync;
    vsync <= in_vsync;
END Behavioral;