----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2023 16:25:42
-- Design Name: 
-- Module Name: ai - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY ai IS
    --  Port ( );
    PORT (
        led : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        sys_clk : IN STD_LOGIC;
        sync_clk : IN STD_LOGIC;
        paddle_size : IN INTEGER;
        paddle_length : IN INTEGER;
        ai_level_1_x : INOUT INTEGER;
        ai_level_1_y : INOUT INTEGER;
        ai_level_2_x : INOUT INTEGER;
        ai_level_2_y : INOUT INTEGER;
        ai_level_3_x : INOUT INTEGER;
        ai_level_3_y : INOUT INTEGER;
        ai_fatigue_x : INOUT INTEGER;
        ai_fatigue_y : INOUT INTEGER;
        ai_sd_x : INOUT INTEGER;
        ai_sd_y : INOUT INTEGER;
        ai_dx : IN INTEGER;
        ai_dy : IN INTEGER;
        ball_x : IN INTEGER;
        ball_y : IN INTEGER;
        ball_dx : IN INTEGER;
        ball_dy : IN INTEGER;
        game_reset : IN STD_LOGIC;
        is_ai : IN STD_LOGIC;
        is_end : IN STD_LOGIC;
        ai_state : INOUT INTEGER;
        player1_score : IN INTEGER;
        player2_score : IN INTEGER

    );
END ai;

ARCHITECTURE Behavioral OF ai IS

    -- Components
    COMPONENT clock_divider IS
        GENERIC (N : INTEGER);
        PORT (
            CLK_IN : IN STD_LOGIC;
            CLK_OUT : OUT STD_LOGIC
        );
    END COMPONENT;

    -- VGA constants
    CONSTANT H_START : INTEGER := 48 + 240 - 1;
    CONSTANT H_END : INTEGER := 1344 - 32 - 1;
    CONSTANT V_START : INTEGER := 3 + 12 - 1;
    CONSTANT V_END : INTEGER := 625 - 10 - 1;

    -- Paddle Constants
    CONSTANT INIT_PADDLE_X : INTEGER := H_START + 70;
    CONSTANT INIT_PADDLE_Y : INTEGER := V_START + 260;

    -- Singals
    SIGNAL clk20Hz, clk30Hz, clk40Hz, clk50Hz : STD_LOGIC;

    -- AI Parameters
    CONSTANT INIT_DETECTION1_RANGE : INTEGER := 200;
    CONSTANT INIT_DETECTION2_RANGE : INTEGER := 300;
    CONSTANT INIT_DETECTION3_RANGE : INTEGER := 350;
    CONSTANT INIT_FATIGUE_DETECTION_RANGE : INTEGER := 600;
    SIGNAL ai_ball_range : INTEGER := INIT_DETECTION1_RANGE;
    SIGNAL od_time : INTEGER := 0;
    SIGNAL od_signal : STD_LOGIC;
    SIGNAL rec_time : INTEGER := 0;
    SIGNAL rec_signal : STD_LOGIC;
    SIGNAL sd_time : INTEGER := 0;
    SIGNAL ai_change_phase : STD_LOGIC := '0';
    SIGNAL sded : STD_LOGIC := '0';
    SIGNAL prev_x : INTEGER;
    SIGNAL prev_y : INTEGER;

BEGIN
    -- 1hz = 50000000
    ai_clk20hz : clock_divider GENERIC MAP(N => 2500000)
    PORT MAP(sys_clk, clk20Hz);
    ai_clk30hz : clock_divider GENERIC MAP(N => 1666667)
    PORT MAP(sys_clk, clk30Hz);
    ai_clk40hz : clock_divider GENERIC MAP(N => 1250000)
    PORT MAP(sys_clk, clk40Hz);
    ai_clk50hz : clock_divider GENERIC MAP(N => 1000000)
    PORT MAP(sys_clk, clk50Hz);

    -- AI State Machine
    PROCESS (sync_clk, player1_score, player2_score, ai_state)
    BEGIN
        IF (rising_edge(sync_clk) AND is_ai = '1') THEN
            -- Force to enter state 5 when player score = 9
            IF (player1_score = 9 AND sded = '0') THEN
                ai_change_phase <= '1';
                ai_state <= 5;
            END IF;
            IF (game_reset = '1') THEN
                ai_state <= 1;
            END IF;
            CASE(ai_state) IS
                -- Dynamic Difficulties
                -- ai_ball_range to detect the ball increase gradually
                -- AI clock increase gradually

                -- Level 1
                -- Player1 score range is [0, 2]
                -- AI clock = 30hz
                WHEN 1 =>
                led <= "1000";
                sded <= '0';
                sd_time <= 0;
                od_time <= 0;
                rec_time <= 0;
                ai_ball_range <= INIT_DETECTION1_RANGE;
                -- Slightly increase AI's frenquency
                IF (player1_score > 2 AND player1_score <= 3) THEN
                    ai_state <= 2;
                END IF;

                -- Level 2
                -- Player1 score range is [3, 5]
                -- AI clock = 40hz
                WHEN 2 =>
                led <= "0100";
                od_time <= 0;
                ai_ball_range <= INIT_DETECTION2_RANGE;
                od_signal <= '0';
                IF (player1_score > 5 AND player1_score <= 6) THEN
                    ai_state <= 3;
                END IF;

                -- Level 3
                -- Player1 score range is above 6
                -- AI clock = 50hz
                -- Over Drive
                -- Randomly perform strong hit
                -- Enter fatigue state for a certain time
                WHEN 3 =>
                led <= "1111";
                ai_change_phase <= '0';
                rec_time <= 0;
                ai_ball_range <= INIT_DETECTION3_RANGE;
                od_time <= od_time + 1;
                IF (od_time > 900 AND ball_dx < 0 AND ball_x < H_START + 512) THEN
                    ai_change_phase <= '1';
                    rec_time <= 0;
                    ai_state <= 4;
                END IF;

                -- Fatigue
                -- Wait for a certain time to recover (back to overdrive)
                WHEN 4 =>
                led <= "0110";
                ai_change_phase <= '0';
                od_time <= 0;
                od_signal <= '0';
                ai_ball_range <= INIT_FATIGUE_DETECTION_RANGE;
                rec_time <= rec_time + 1;
                IF (rec_time > 300 AND ball_dx < 0 AND ball_x < H_START + 512) THEN
                    ai_change_phase <= '1';
                    od_time <= 0;
                    ai_state <= 3;
                END IF;

                -- Final State
                -- Player score = 9, -1 to win
                -- AI clock = 60hz
                -- Every hit becomes strong hit
                -- Return to Over Drive state after 30seconds
                WHEN 5 =>
                led <= "1001";
                sded <= '1';
                sd_time <= sd_time + 1;
                ai_change_phase <= '0';
                IF (sd_time > 1800) THEN
                    ai_change_phase <= '1';
                    ai_state <= 3;
                END IF;

                WHEN OTHERS =>
                led <= "0000";
                ai_state <= 1;
            END CASE;
        END IF;
    END PROCESS;

    -- Level 1
    -- Base clock is 30hz
    PROCESS (clk30Hz, ai_state)
    BEGIN
        IF (rising_edge(clk30Hz) AND is_ai = '1' AND ai_state = 1) THEN
            IF (game_reset = '1') THEN
                ai_level_1_x <= INIT_PADDLE_X + 878;
                ai_level_1_y <= INIT_PADDLE_Y;
            ELSE
                -- Movements
                -- Only perform movement when the ball is within the detect range
                IF (H_END - ball_x < ai_ball_range) THEN
                    -- Ball is upper
                    IF ((ai_level_1_y + (PADDLE_LENGTH/2)) - ball_y > 0) THEN
                        IF (ai_level_1_y >= V_START + 70)
                            THEN
                            ai_level_1_y <= ai_level_1_y - ai_dy;
                        ELSE
                            ai_level_1_y <= ai_level_1_y;
                        END IF;
                    ELSE
                        -- Ball is lower
                        IF (ai_level_1_y + PADDLE_LENGTH <= V_START + 510)
                            THEN
                            ai_level_1_y <= ai_level_1_y + ai_dy;
                        ELSE
                            ai_level_1_y <= ai_level_1_y;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Level 2
    -- Base clock is 40hz
    PROCESS (clk40Hz, ai_state)
    BEGIN
        IF (rising_edge(clk40Hz) AND is_ai = '1' AND ai_state = 2) THEN
            IF (game_reset = '1') THEN
                ai_level_2_x <= INIT_PADDLE_X + 878;
                ai_level_2_y <= INIT_PADDLE_Y;
            ELSE
                -- Movements
                -- Only perform movement when the ball is within the detect range
                IF (H_END - ball_x < ai_ball_range) THEN
                    -- Ball is upper
                    IF ((ai_level_2_y + (PADDLE_LENGTH/2)) - ball_y > 0) THEN
                        IF (ai_level_2_y >= V_START + 70)
                            THEN
                            ai_level_2_y <= ai_level_2_y - ai_dy;
                        ELSE
                            ai_level_2_y <= ai_level_2_y;
                        END IF;
                    ELSE
                        -- Ball is lower
                        IF (ai_level_2_y + PADDLE_LENGTH <= V_START + 510)
                            THEN
                            ai_level_2_y <= ai_level_2_y + ai_dy;
                        ELSE
                            ai_level_2_y <= ai_level_2_y;
                        END IF;
                    END IF;
                    -- Try to go back to middle to focus on defence
                ELSE
                    IF (ai_level_2_y > INIT_PADDLE_Y) THEN
                        ai_level_2_y <= ai_level_2_y - ai_dy;
                    ELSE
                        ai_level_2_y <= ai_level_2_y + ai_dy;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Level 3
    -- Over Drive
    -- Base clock is 50hz
    PROCESS (clk50Hz, ai_state, ai_change_phase)
    BEGIN
        IF (rising_edge(clk40Hz) AND is_ai = '1' AND ai_state = 3) THEN
            IF (game_reset = '1' OR ai_change_phase = '1') THEN
                ai_level_3_x <= INIT_PADDLE_X + 878;
                ai_level_3_y <= INIT_PADDLE_Y;
            ELSE
                -- Movements
                -- Only perform movement when the ball is within the detect range
                IF (H_END - ball_x < ai_ball_range) THEN
                    -- Ball is upper
                    IF ((ai_level_3_y + (PADDLE_LENGTH/2)) - ball_y > 0) THEN
                        IF (ai_level_3_y >= V_START + 70)
                            THEN
                            ai_level_3_y <= ai_level_3_y - ai_dy;
                        ELSE
                            ai_level_3_y <= ai_level_3_y;
                        END IF;
                    ELSE
                        -- Ball is lower
                        IF (ai_level_3_y + PADDLE_LENGTH <= V_START + 510)
                            THEN
                            ai_level_3_y <= ai_level_3_y + ai_dy;
                        ELSE
                            ai_level_3_y <= ai_level_3_y;
                        END IF;
                    END IF;
                    -- Try to go back to middle to focus on defence
                ELSE
                    IF (ai_level_3_y > INIT_PADDLE_Y) THEN
                        ai_level_3_y <= ai_level_3_y - ai_dy;
                    ELSE
                        ai_level_3_y <= ai_level_3_y + ai_dy;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- 4 => Fatigue
    -- Base clock is 20hz
    PROCESS (clk20Hz, ai_state, ai_change_phase)
    BEGIN
        IF (rising_edge(clk20Hz) AND is_ai = '1' AND ai_state = 4) THEN
            IF (game_reset = '1' OR ai_change_phase = '1') THEN
                ai_fatigue_x <= INIT_PADDLE_X + 878;
                ai_fatigue_y <= INIT_PADDLE_Y;
            ELSE
                -- Movements
                -- Only perform movement when the ball is within the detect range
                IF (H_END - ball_x < ai_ball_range) THEN
                    -- Ball is upper
                    IF ((ai_fatigue_y + (PADDLE_LENGTH/2)) - ball_y > 0) THEN
                        IF (ai_fatigue_y >= V_START + 70)
                            THEN
                            ai_fatigue_y <= ai_fatigue_y - ai_dy;
                        ELSE
                            ai_fatigue_y <= ai_fatigue_y;
                        END IF;
                    ELSE
                        -- Ball is lower
                        IF (ai_fatigue_y + PADDLE_LENGTH <= V_START + 510)
                            THEN
                            ai_fatigue_y <= ai_fatigue_y + ai_dy;
                        ELSE
                            ai_fatigue_y <= ai_fatigue_y;
                        END IF;
                    END IF;
                    -- Try to go back to middle to focus on defence
                ELSE
                    IF (ai_fatigue_y > INIT_PADDLE_Y) THEN
                        ai_fatigue_y <= ai_fatigue_y - ai_dy;
                    ELSE
                        ai_fatigue_y <= ai_fatigue_y + ai_dy;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Final State
    -- 5 => when player reaches 9score
    -- This state can only maintain for 30 seconds
    -- 60hz
    -- Always strong hit
    -- Possibilties to use illusion ball
    PROCESS (sync_clk, ai_state, ai_change_phase)
    BEGIN
        IF (rising_edge(sync_clk) AND is_ai = '1' AND ai_state = 5) THEN
            IF (game_reset = '1') THEN
                ai_sd_x <= INIT_PADDLE_X + 878;
                ai_sd_y <= INIT_PADDLE_Y;
            ELSE
                -- Movements
                -- Only perform movement when the ball is within the detect range
                IF (H_END - ball_x < ai_ball_range) THEN
                    -- Ball is upper
                    IF ((ai_sd_y + (PADDLE_LENGTH/2)) - ball_y > 0) THEN
                        IF (ai_sd_y >= V_START + 70)
                            THEN
                            ai_sd_y <= ai_sd_y - ai_dy;
                        ELSE
                            ai_sd_y <= ai_sd_y;
                        END IF;
                    ELSE
                        -- Ball is lower
                        IF (ai_sd_y + PADDLE_LENGTH <= V_START + 510)
                            THEN
                            ai_sd_y <= ai_sd_y + ai_dy;
                        ELSE
                            ai_sd_y <= ai_sd_y;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;