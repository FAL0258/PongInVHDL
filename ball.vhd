----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.05.2023 16:39:07
-- Design Name: 
-- Module Name: ball - Behavioral
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
USE IEEE.Numeric_Std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY ball IS
    --  Port ( );
    PORT (
        clk_ball : IN STD_LOGIC;
        vib_1 : BUFFER STD_LOGIC;
        vib_2 : BUFFER STD_LOGIC;
        is_end : IN STD_LOGIC;
        BALL_SIZE : IN INTEGER;
        ball_x : INOUT INTEGER;
        ball_y : INOUT INTEGER;
        ball_dx : INOUT INTEGER;
        ball_dy : INOUT INTEGER;
        illusion_ball_x : INOUT INTEGER;
        illusion_ball_y : INOUT INTEGER;
        ball_startx_offset : IN INTEGER;
        ball_starty_offset : IN INTEGER;
        BALL_X_BASESTEP : IN INTEGER;
        ILLUSION_BALL_X_BASESTEP : IN INTEGER;
        ILLUSION_BALL_Y_BASESTEP : IN INTEGER;
        PADDLE_SIZE : IN INTEGER;
        P1_PADDLE_LENGTH : IN INTEGER;
        P2_PADDLE_LENGTH : IN INTEGER;
        strong_hit_multiplier : IN INTEGER;
        weak_hit_multiplier : IN INTEGER;
        is_left_miss : INOUT STD_LOGIC;
        is_right_miss : INOUT STD_LOGIC;
        p1_x : IN INTEGER;
        p1_y : IN INTEGER;
        p2_real_x : IN INTEGER;
        p2_real_y : IN INTEGER;
        ai_state : IN INTEGER;
        is_ai : IN STD_LOGIC;
        is_strong : OUT STD_LOGIC;
        is_weak : OUT STD_LOGIC;
        illusion_ball_trigger : INOUT STD_LOGIC;
        player1_control_signal : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        player2_control_signal : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        pseudo_rand : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ball;

ARCHITECTURE Behavioral OF ball IS
    -- VGA
    CONSTANT H_START : INTEGER := 48 + 240 - 1;
    CONSTANT H_END : INTEGER := 1344 - 32 - 1;
    CONSTANT V_START : INTEGER := 3 + 12 - 1;
    CONSTANT V_END : INTEGER := 625 - 10 - 1;

    -- Ball configuration
    CONSTANT INIT_X : INTEGER := H_START + 505;
    CONSTANT INIT_Y : INTEGER := V_START + 300;

    -- Illusion Ball
    SIGNAL X_STEP : INTEGER := ILLUSION_BALL_X_BASESTEP;
    SIGNAL Y_STEP : INTEGER := ILLUSION_BALL_Y_BASESTEP;
    SIGNAL illusion_ball_dx : INTEGER := X_STEP;
    SIGNAL illusion_ball_dy : INTEGER := Y_STEP;
    SIGNAL illusion_is_init : STD_LOGIC := '0';

BEGIN

    -- Ball handler
    PROCESS (clk_ball, is_end)
    BEGIN
        IF (rising_edge(clk_ball)) THEN
            IF (is_end = '1') THEN
                ball_x <= INIT_X;
                ball_y <= INIT_Y;
                ball_dx <= X_STEP + ball_startx_offset;
                ball_dy <= Y_STEP + ball_starty_offset;
                is_left_miss <= '0';
                is_right_miss <= '0';
                is_strong <= '0';
                is_weak <= '0';
                vib_1 <= '0';
                vib_2 <= '0';
            ELSE
                -- Let the vibration last longer
                IF (ball_x - p1_x > 150) THEN
                    vib_1 <= '0';
                END IF;
                IF (p2_real_x - ball_x > 150 AND is_ai = '0') THEN
                    vib_2 <= '0';
                END IF;
                ball_x <= ball_x + ball_dx;
                ball_y <= ball_y + ball_dy;
                --                IF (ready_to_vib = '0') THEN
                --                    vib1_signal <= '0';
                --                    vib2_signal <= '0';
                --                END IF;
                -- Tune to make it rebounds accurately
                -- Touch bottom wall
                IF (ball_y + BALL_SIZE >= V_END - 85) THEN
                    ball_dy <= - Y_STEP;
                    -- Touch top wall
                ELSIF (ball_y <= V_START + 80) THEN
                    ball_dy <= Y_STEP;
                    -- Touch right
                ELSIF (p2_real_x - ball_x > 0 AND p2_real_x - ball_x <= 50) THEN
                    IF
                        -- Threshold to see if it is hit
                        ((p2_real_x - ball_x - BALL_SIZE <= 50 AND p2_real_x - ball_x - BALL_SIZE >- 10)
                        AND
                        (p2_real_y + P2_PADDLE_LENGTH - ball_y <= 60)
                        AND
                        (p2_real_y + P2_PADDLE_LENGTH - ball_y >- 30))
                        THEN
                        IF (is_ai = '0') THEN
                            vib_2 <= '1';
                        END IF;
                        -- Apply strong hit if player2 is pressing left button when hit
                        -- Apply force strong hit when ai enters state 5
                        IF (is_ai = '1')
                            THEN
                            -- Final state
                            -- Randomly perform illusion ball + 100percent strong hit
                            -- Approximate 70percent to perform
                            IF (ai_state = 5 AND (to_integer(unsigned(pseudo_rand)) MOD 10 <= 6)) THEN
                                ball_dx <= - (X_STEP + strong_hit_multiplier);
                                illusion_ball_trigger <= '1';
                                is_strong <= '1';
                                is_weak <= '0';
                            -- Over Drive
                            -- Randomly perform strong hit + 100percent illusion ball when ai is state 3
                            -- Approximate 66.6percent to perform
                            ELSIF ((to_integer(unsigned(pseudo_rand)) MOD 9 <= 5) AND ai_state = 3) THEN
                                ball_dx <= - (X_STEP + strong_hit_multiplier);
                                illusion_ball_trigger <= '1';
                                is_strong <= '1';
                                is_weak <= '0';
                            ELSIF (ai_state = 3) THEN
                                ball_dx <= - (X_STEP);
                                illusion_ball_trigger <= '1';
                                is_strong <= '0';
                                is_weak <= '0';
                            ELSIF (ai_state = 5) THEN
                                ball_dx <= - (X_STEP);
                                is_strong <= '1';
                                is_weak <= '0';
                            ELSE
                                ball_dx <= - BALL_X_BASESTEP;
                                is_strong <= '0';
                                is_weak <= '0';
                            END IF;
                        ELSIF (player2_control_signal = "0010") THEN
                            ball_dx <= - (X_STEP + weak_hit_multiplier);
                            is_strong <= '1';
                            is_weak <= '0';    
                        -- Apply weak hit if player2 is pressing right button when hit
                        ELSIF (player2_control_signal = "0001") THEN
                            ball_dx <= - (X_STEP - weak_hit_multiplier);
                            is_strong <= '0';
                            is_weak <= '1';
                        -- Normal hit
                        ELSE
                            ball_dx <= - BALL_X_BASESTEP;
                            is_strong <= '0';
                            is_weak <= '0';
                        END IF;
                    END IF;
                ELSIF (ball_x >= H_END - 49) THEN
                    is_right_miss <= '1';
                -- Touch left
                ELSIF (ball_x - p1_x > 0 AND ball_x - p1_x <= 50) THEN
                    IF
                        -- Threshold to see if it is hit
                        ((ball_x - p1_x - PADDLE_SIZE <= 50 AND ball_x - p1_x - PADDLE_SIZE >- 10)
                        AND
                        ( p1_y + P1_PADDLE_LENGTH - ball_y <= 60)
                        AND
                        ( p1_y + P1_PADDLE_LENGTH - ball_y >- 30))
                        THEN
                        vib_1 <= '1';
                        illusion_ball_trigger <= '0';
                        -- Apply strong hit if player1 is pressing right button when hit
                        IF (player1_control_signal = "0001") THEN
                            ball_dx <= (X_STEP + strong_hit_multiplier);
                            is_strong <= '1';
                            is_weak <= '0';
                            -- Apply weak hit if player1 is pressing left button when hit
                        ELSIF (player1_control_signal = "0010") THEN
                            ball_dx <= (X_STEP - weak_hit_multiplier);
                            is_strong <= '0';
                            is_weak <= '1';
                            -- Normal hit
                        ELSE
                            ball_dx <= X_STEP;
                            is_strong <= '0';
                            is_weak <= '0';
                        END IF;
                    END IF;
                ELSIF (ball_x <= H_START + 50) THEN
                    illusion_ball_trigger <= '0';
                    is_left_miss <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- illusion Ball Handler
    PROCESS (clk_ball, illusion_ball_trigger, is_left_miss)
    BEGIN
        IF (rising_edge(clk_ball) AND illusion_ball_trigger = '1') THEN
            IF (illusion_is_init = '0') THEN
                illusion_is_init <= '1';
                illusion_ball_x <= ball_x;
                illusion_ball_y <= ball_y;
                illusion_ball_dx <= ball_dx;
                illusion_ball_dy <= - ball_dy;
            ELSE
                illusion_ball_x <= illusion_ball_x + illusion_ball_dx;
                illusion_ball_y <= illusion_ball_y + illusion_ball_dy;
                -- Touch bottom
                IF (illusion_ball_y + BALL_SIZE >= V_END - 85) THEN
                    illusion_ball_dy <= - Y_STEP;
                    -- Touch top wall
                ELSIF (illusion_ball_y <= V_START + 80) THEN
                    illusion_ball_dy <= Y_STEP;
                END IF;
                IF (is_left_miss = '1' OR illusion_ball_x <= H_START + 50 OR illusion_ball_x - 100 <= p1_x) THEN
                    illusion_is_init <= '0';
                END IF;
            END IF;

        END IF;
    END PROCESS;

END Behavioral;