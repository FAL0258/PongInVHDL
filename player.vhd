----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2023 15:33:11
-- Design Name: 
-- Module Name: player - Behavioral
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

ENTITY player IS
    --  Port ( );
    PORT (
        clk : IN STD_LOGIC;
        player_control_signal : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        paddle_size : IN INTEGER;
        paddle_length : IN INTEGER;
        player_x : BUFFER INTEGER;
        player_y : BUFFER INTEGER;
        player_dx : IN INTEGER;
        player_dy : IN INTEGER;
        is_frenzy : IN STD_LOGIC;
        game_reset : IN STD_LOGIC;
        is_ai : IN STD_LOGIC;
        is_poison : IN STD_LOGIC;
        is_p2 : IN STD_LOGIC

    );
END player;

ARCHITECTURE Behavioral OF player IS
    -- VGA constants
    CONSTANT H_START : INTEGER := 48 + 240 - 1;
    CONSTANT H_END : INTEGER := 1344 - 32 - 1;
    CONSTANT V_START : INTEGER := 3 + 12 - 1;
    CONSTANT V_END : INTEGER := 625 - 10 - 1;

    -- Paddle Constants
    CONSTANT INIT_PADDLE_X : INTEGER := H_START + 70;
    CONSTANT INIT_PADDLE_Y : INTEGER := V_START + 260;

BEGIN
    -- Player Paddle (Left hand side / Right hand side is_p2 = '1')
    PROCESS (clk, player_control_signal)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (game_reset = '1') THEN
                IF (is_p2 = '0') THEN
                    player_x <= INIT_PADDLE_X;
                    player_y <= INIT_PADDLE_Y;
                ELSE
                    player_x <= INIT_PADDLE_X + 878;
                    player_y <= INIT_PADDLE_Y;
                END IF;
            ELSE
                IF (is_p2 = '0') THEN
                    IF (is_poison = '0') THEN
                        CASE (player_control_signal) IS
                                -- Means going up
                            WHEN("1000") =>
                                IF (player_y >= V_START + 70)
                                    THEN
                                    player_y <= player_y - player_dy;
                                ELSE
                                END IF;
                                -- Means going down
                            WHEN("0100") =>
                                IF (player_y + PADDLE_LENGTH <= V_START + 510)
                                    THEN
                                    player_y <= player_y + player_dy;
                                ELSE
                                END IF;
                                -- Means going left (only in frenzy mode)
                            WHEN("0010") =>
                                IF (player_x >= H_START + 80 AND is_frenzy = '1')
                                    THEN
                                    player_x <= player_x - player_dx;
                                ELSE
                                END IF;
                                -- Means going right (only in frenzy mode)
                            WHEN("0001") =>
                                IF (player_x + PADDLE_SIZE <= H_START + 450 AND is_frenzy = '1')
                                    THEN
                                    player_x <= player_x + player_dx;
                                ELSE
                                END IF;
                            WHEN OTHERS =>
                                player_x <= player_x;
                                player_y <= player_y;
                        END CASE;
                    ELSE
                        -- Poison state
                        CASE (player_control_signal) IS
                            -- Means going up but down
                            WHEN("1000") =>
                                IF (player_y + PADDLE_LENGTH <= V_START + 510)
                                    THEN
                                    player_y <= player_y + player_dy;
                                ELSE
                                
                                END IF;
                            -- Means going down but up
                            WHEN("0100") =>
                                IF (player_y >= V_START + 70)
                                THEN
                                    player_y <= player_y - player_dy;
                                ELSE
                                END IF;
                            -- Means going left but right
                            WHEN("0010") =>
                                IF (player_x + PADDLE_SIZE <= H_START + 450 AND is_frenzy = '1')
                                    THEN
                                    player_x <= player_x + player_dx;
                                ELSE
                                END IF;
                                -- Means going right but left
                            WHEN("0001") =>
                                IF (player_x >= H_START + 80 AND is_frenzy = '1')
                                    THEN
                                    player_x <= player_x - player_dx;
                                ELSE
                                END IF;
                            WHEN OTHERS =>
                                player_x <= player_x;
                                player_y <= player_y;
                        END CASE;
                    END IF;
                ELSE
                    IF (is_ai = '0' AND is_poison = '0') THEN
                        CASE (player_control_signal) IS
                                -- Means going up
                            WHEN("1000") =>
                                IF (player_y >= V_START + 70)
                                    THEN
                                    player_y <= player_y - player_dy;
                                ELSE
                                END IF;
                                -- Means going down
                            WHEN("0100") =>
                                IF (player_y + PADDLE_LENGTH <= V_START + 510)
                                    THEN
                                    player_y <= player_y + player_dy;
                                ELSE
                                END IF;
                                -- Means going left
                            WHEN("0010") =>
                                IF (player_x + PADDLE_SIZE >= H_START + 600 AND is_frenzy = '1')
                                    THEN
                                    player_x <= player_x - player_dx;
                                ELSE
                                END IF;
                                -- Means going right
                            WHEN("0001") =>
                                IF (player_x + PADDLE_SIZE <= H_END - 70 AND is_frenzy = '1')
                                    THEN
                                    player_x <= player_x + player_dx;
                                ELSE
                                END IF;
                            WHEN OTHERS =>
                                player_x <= player_x;
                                player_y <= player_y;
                        END CASE;
                    -- Poison state
                    ELSIF (is_ai = '0' AND is_poison = '1') THEN
                    CASE (player_control_signal) IS
                        -- Means going up but down
                        WHEN("1000") =>
                            IF (player_y + PADDLE_LENGTH <= V_START + 510)
                            THEN
                                player_y <= player_y + player_dy;
                            ELSE
                            END IF;
                        -- Means going down but up
                        WHEN("0100") =>
                            IF (player_y >= V_START + 70)
                                THEN
                                player_y <= player_y - player_dy;
                            ELSE
                            END IF;
                        -- Means going left but right
                        WHEN("0010") =>
                            IF (player_x + PADDLE_SIZE <= H_END - 70 AND is_frenzy = '1')
                            THEN
                                player_x <= player_x + player_dx;
                            ELSE
                            END IF;
                            
                        -- Means going right but left
                        WHEN("0001") =>
                            IF (player_x + PADDLE_SIZE >= H_START + 600 AND is_frenzy = '1')
                                THEN
                                player_x <= player_x - player_dx;
                            ELSE
                            END IF;
                        WHEN OTHERS =>
                            player_x <= player_x;
                            player_y <= player_y;
                    END CASE;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;