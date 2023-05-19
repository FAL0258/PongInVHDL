LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY item_generator IS
    PORT (
        clk_ball, clk_item : IN STD_LOGIC;
        game_begin : IN STD_LOGIC;
        p1_item_trigger : INOUT INTEGER;
        p2_item_trigger : INOUT INTEGER;
        PADDLE_SIZE : IN INTEGER;
        P1_PADDLE_LENGTH : INOUT INTEGER;
        P2_PADDLE_LENGTH : INOUT INTEGER;
        P1_PADDLE_DX : INOUT INTEGER;
        P2_PADDLE_DX : INOUT INTEGER;
        P1_PADDLE_DY : INOUT INTEGER;
        P2_PADDLE_DY : INOUT INTEGER;
        p1_x : IN INTEGER;
        p1_y : IN INTEGER;
        p2_real_x : IN INTEGER;
        p2_real_y : IN INTEGER;
        p1_item_x : INOUT INTEGER;
        p1_item_y : INOUT INTEGER;
        p2_item_x : INOUT INTEGER;
        p2_item_y : INOUT INTEGER;
        p1_item_ready : OUT STD_LOGIC;
        p2_item_ready : OUT STD_LOGIC;
        is_ai : IN STD_LOGIC;
        is_frenzy : IN STD_LOGIC;
        is_long_p1 : OUT STD_LOGIC;
        is_long_p2 : OUT STD_LOGIC;
        is_speed_p1 : OUT STD_LOGIC;
        is_speed_p2 : OUT STD_LOGIC;
        is_poison_p1 : OUT STD_LOGIC;
        is_poison_p2 : OUT STD_LOGIC;
        pseudo_rand : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    );

END item_generator;

ARCHITECTURE Behavioral OF item_generator IS

    -- VGA
    CONSTANT H_START : INTEGER := 48 + 240 - 1;
    CONSTANT H_END : INTEGER := 1344 - 32 - 1;
    CONSTANT V_START : INTEGER := 3 + 12 - 1;
    CONSTANT V_END : INTEGER := 625 - 10 - 1;

    -- Area V range = [112, 498] = 386
    -- P1 Area H range = [395, 711] = 316
    -- 395
    CONSTANT P1_H_START : INTEGER := H_START + 81 + 27;
    -- 711
    CONSTANT P1_H_END : INTEGER := H_START + 451 - 27;
    -- 112
    CONSTANT P1_V_START : INTEGER := V_START + 71 + 27;
    -- 498
    CONSTANT P1_V_END : INTEGER := V_START + 511 - 27;
    -- P2 Area H range = [915, 1213] = 298
    -- 915
    CONSTANT P2_H_START : INTEGER := H_START + 601 + 27;
    -- 1213
    CONSTANT P2_H_END : INTEGER := H_END - 71 - 27;
    -- 112
    CONSTANT P2_V_START : INTEGER := V_START + 71 + 27;
    -- 498
    CONSTANT P2_V_END : INTEGER := V_START + 511 - 27;

    -- Item generation
    CONSTANT ori_p1_paddle_length : INTEGER := 60;
    CONSTANT ori_p1_paddle_dx : INTEGER := 5;
    CONSTANT ori_p1_paddle_dy : INTEGER := 5;
    CONSTANT ori_p2_paddle_length : INTEGER := 60;
    CONSTANT ori_p2_paddle_dx : INTEGER := 5;
    CONSTANT ori_p2_paddle_dy : INTEGER := 5;

    CONSTANT paddle_dx_mod : INTEGER := 7;
    CONSTANT paddle_dy_mod : INTEGER := 7;
    CONSTANT paddle_length_mod : INTEGER := 90;

    SIGNAL prev_rand : INTEGER := 0;
    SIGNAL p1_item_counter : INTEGER := 0;
    SIGNAL p2_item_counter : INTEGER := 0;
    SIGNAL p1_item_ok : STD_LOGIC := '1';
    SIGNAL p2_item_ok : STD_LOGIC := '1';
    SIGNAL p1_item_type : INTEGER := -1;
    SIGNAL p2_item_type : INTEGER := -1;
    SIGNAL p1_item_get : INTEGER := -1;
    SIGNAL p2_item_get : INTEGER := -1;
    SIGNAL p1_effect_counter : INTEGER := 0;
    SIGNAL p2_effect_counter : INTEGER := 0;

BEGIN

    -- Process for generating items
    -- clk_item running at 1Hz
    -- Manage to make it every 5 seconds
    -- Count = 5 for every rising edge
    PROCESS(clk_item, game_begin, p1_item_get, p2_item_get)
    BEGIN
        prev_rand <= to_integer(unsigned(pseudo_rand));
        IF (rising_edge(clk_item) AND game_begin = '1' AND is_ai = '0' AND is_frenzy = '1') THEN
            -- Check if the effect time is up
            IF (p1_item_get /= -1 AND p1_effect_counter <= 5) THEN
                p1_item_ready <= '0';
                p1_effect_counter <= p1_effect_counter + 1;
                p1_item_ok <= '0';
            ELSIF (p1_effect_counter > 5) THEN
                p1_item_ready <= '0';
                p1_item_trigger <= -1;
                p1_item_counter <= 0;
                p1_effect_counter <= 0;
                p1_item_ok <= '1';
            END IF;

            IF (p2_item_get /= -1 AND p2_effect_counter <= 5) THEN
                p2_item_ready <= '0';
                p2_effect_counter <= p2_effect_counter + 1;
                p2_item_ok <= '0';
            ELSIF (p2_effect_counter > 5) THEN
                p2_item_ready <= '0';
                p2_item_trigger <= -1;
                p2_item_counter <= 0;
                p2_effect_counter <= 0;
                p2_item_ok <= '1';
            END IF;

            -- Only spawn item when effect time is up + extra item refresh
            -- Restore all the state of p1
            IF (p1_item_counter < 5 AND p1_item_ok = '1') THEN
                p1_item_ready <= '0';
                p1_item_trigger <= -1;
                p1_item_counter <= p1_item_counter + 1;
                -- Use to_integer(unsigned(pseudo_rand)) to generate item's x and y coordinates
                p1_item_x <= P1_H_START + (to_integer(unsigned(pseudo_rand)) mod 316);
                p1_item_y <= P1_V_START + ((to_integer(unsigned(pseudo_rand)) + to_integer(unsigned(pseudo_rand))) mod 386);
                -- Total 3 possible items
                p1_item_type <= (prev_rand + p1_item_x) mod 3;
            ELSIF (p1_item_counter >= 5 AND p1_item_ok = '1' AND p1_item_get = -1) THEN
                p1_item_ready <= '1';
                -- Decide p1's item
                CASE (p1_item_type) IS
                    -- 0 is boot, increase movement speed
                    WHEN 0 =>
                        p1_item_trigger <= 0;

                    -- 1 is booster, increase paddle length
                    WHEN 1 =>
                        p1_item_trigger <= 1;

                    -- 2 is poison, making movement direction in an inverted way
                    WHEN 2 =>
                        p1_item_trigger <= 2;
                        
                    WHEN OTHERS =>
                END CASE;
            END IF;

            -- Restore all the state of p2
            IF (p2_item_counter < 5 AND p2_item_ok = '1') THEN
                p2_item_ready <= '0';
                p2_item_trigger <= -1;
                p2_item_counter <= p2_item_counter + 1;
                -- Use to_integer(unsigned(pseudo_rand)) to generate item's x and y coordinates
                p2_item_x <= P2_H_START + (prev_rand mod 298);
                p2_item_y <= P2_V_START + ((prev_rand + prev_rand) mod 386);
                -- Total 3 possible items
                p2_item_type <= (prev_rand + p2_item_x) mod 3;
            ELSIF (p2_item_counter >= 5 AND p2_item_ok = '1' AND p2_item_get = -1) THEN
                p2_item_ready <= '1';

                -- Decide p2's item
                CASE (p2_item_type) IS
                    -- 0 is boot, increase movement speed
                    WHEN 0 =>
                        p2_item_trigger <= 0;

                    -- 1 is booster, increase paddle length
                    WHEN 1 =>
                        p2_item_trigger <= 1;

                    -- 2 is poison, making movement direction in an inverted way
                    WHEN 2 =>
                        p2_item_trigger <= 2;

                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- Process to handle getting the item for each of the players
    PROCESS(clk_ball, p1_item_trigger, p2_item_trigger)
    BEGIN
        IF (p1_item_ok = '1') THEN
            p1_item_get <= -1;
        END IF;

        IF (p2_item_ok = '1') THEN
            p2_item_get <= -1;
        END IF;

        IF (p1_item_trigger /= -1) THEN
            -- Means p1 got the item
            IF( (abs(p1_x + PADDLE_SIZE - p1_item_x) < 20 ) AND
                 (abs(p1_y + P1_PADDLE_LENGTH - p1_item_y) < 40)) THEN
                p1_item_get <= p1_item_trigger;
            ELSE
                p1_item_get <= p1_item_get;
            END IF;
        -- Need one elsif to handle effect time's up
        ELSE
            p1_item_get <= -1;
        END IF;

        IF (p2_item_trigger /= -1) THEN
            IF( (abs(p2_real_x + PADDLE_SIZE - p2_item_x) < 20) AND
                (abs(p2_real_y + P2_PADDLE_LENGTH - p2_item_y) < 40)) THEN
                p2_item_get <= p2_item_trigger;
            ELSE
                p2_item_get <= p2_item_get;
            END IF;
        -- Need one elsif to handle effect time's up
        ELSE
            p2_item_get <= -1;
        END IF;
    END PROCESS;

    -- Process to handle the item effects of each of the players
    PROCESS(clk_ball, p1_item_get, p2_item_get)
    BEGIN
        IF(rising_edge(clk_ball)) THEN
            CASE (p1_item_get) IS
                -- Picked Boot
                WHEN 0 =>
                    P1_PADDLE_LENGTH <= ori_p1_paddle_length;
                    p1_paddle_dx <= paddle_dx_mod;
                    p1_paddle_dy <= paddle_dy_mod;
                    is_long_p1 <= '0';
                    is_speed_p1 <= '1';
                    is_poison_p1 <= '0';

                -- Picked Booster
                WHEN 1 =>
                    P1_PADDLE_LENGTH <= paddle_length_mod;
                    P1_PADDLE_DX <= ori_p1_paddle_dx;
                    P1_PADDLE_DY <= ori_p1_paddle_dy;
                    is_long_p1 <= '1';
                    is_speed_p1 <= '0';
                    is_poison_p1 <= '0';

                -- Picked Poison
                WHEN 2 =>
                    P1_PADDLE_LENGTH <= ori_p1_paddle_length;
                    P1_PADDLE_DX <= ori_p1_paddle_dx;
                    P1_PADDLE_DY <= ori_p1_paddle_dy;
                    is_long_p1 <= '0';
                    is_speed_p1 <= '0';
                    is_poison_p1 <= '1';

                -- Resotre all the state
                WHEN OTHERS =>
                    P1_PADDLE_LENGTH <= ori_p1_paddle_length;
                    P1_PADDLE_DX <= ori_p1_paddle_dx;
                    P1_PADDLE_DY <= ori_p1_paddle_dy;
                    is_long_p1 <= '0';
                    is_speed_p1 <= '0';
                    is_poison_p1 <= '0';
            END CASE;

            CASE (p2_item_get) IS
                -- Picked Boot
                WHEN 0 =>
                    P2_PADDLE_LENGTH <= ori_p2_paddle_length;
                    p2_paddle_dx <= paddle_dx_mod;
                    p2_paddle_dy <= paddle_dy_mod;
                    is_long_p2 <= '0';
                    is_speed_p2 <= '1';
                    is_poison_p2 <= '0';

                -- Picked Booster
                WHEN 1 =>
                    P2_PADDLE_LENGTH <= paddle_length_mod;
                    P2_PADDLE_DX <= ori_p2_paddle_dx;
                    P2_PADDLE_DY <= ori_p2_paddle_dy;
                    is_long_p2 <= '1';
                    is_speed_p2 <= '0';
                    is_poison_p2 <= '0';

                -- Picked Poison
                WHEN 2 =>
                    P2_PADDLE_LENGTH <= ori_p2_paddle_length;
                    P2_PADDLE_DX <= ori_p2_paddle_dx;
                    P2_PADDLE_DY <= ori_p2_paddle_dy;
                    is_long_p2 <= '0';
                    is_speed_p2 <= '0';
                    is_poison_p2 <= '1';

                -- Resotre all the state
                WHEN OTHERS =>
                    P2_PADDLE_LENGTH <= ori_p2_paddle_length;
                    P2_PADDLE_DX <= ori_p2_paddle_dx;
                    P2_PADDLE_DY <= ori_p2_paddle_dy;
                    is_long_p2 <= '0';
                    is_speed_p2 <= '0';
                    is_poison_p2 <= '0';

            END CASE;
        END IF;
    END PROCESS;

END Behavioral;