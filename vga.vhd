----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.05.2023 20:13:59
-- Design Name: 
-- Module Name: vga - Behavioral
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

ENTITY vga IS
    --  Port ( );
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
END vga;

ARCHITECTURE Behavioral OF vga IS

    -- Player Component
    COMPONENT player IS
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
    END COMPONENT;

    -- AI Component
    COMPONENT ai IS
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
    END COMPONENT;

    -- Ball component
    COMPONENT ball IS
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
    END COMPONENT;

    -- Item component
    COMPONENT item_generator IS
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
    END COMPONENT;

    -- NUMBER DISPLAY
    TYPE displayArr IS ARRAY(0 TO 8, 0 TO 8) OF INTEGER;
    TYPE longdisplayArr IS ARRAY(0 TO 8, 0 TO 53) OF INTEGER;
    CONSTANT Num_0 : displayArr :=
    (
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 1, 0, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 1, 0, 1, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0));

    CONSTANT Num_1 : displayArr :=
    (
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 1, 1, 0, 0, 0, 0),
    (0, 0, 1, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0));

    CONSTANT Num_2 : displayArr :=
    (
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 1, 0, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 1, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 1, 0, 0, 0, 0, 0),
    (0, 0, 1, 1, 1, 1, 1, 1, 0));

    CONSTANT Num_3 : displayArr :=
    (
    (0, 0, 0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 1, 1, 1, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 1, 1, 1, 0, 0, 0));

    CONSTANT Num_4 : displayArr :=
    (
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 1, 1, 0, 0, 0, 0),
    (0, 0, 1, 0, 1, 0, 0, 0, 0),
    (0, 1, 0, 0, 1, 0, 0, 0, 0),
    (0, 1, 1, 1, 1, 1, 1, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0));

    CONSTANT Num_5 : displayArr :=
    (
    (0, 0, 1, 1, 1, 1, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 0, 0, 0),
    (0, 0, 1, 0, 1, 0, 0, 0, 0),
    (0, 0, 1, 1, 0, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 1, 1, 1, 0, 0, 0));

    CONSTANT Num_6 : displayArr :=
    (
    (0, 0, 0, 0, 0, 1, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 1, 0, 0, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 0, 0, 0),
    (0, 0, 1, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 1, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 1, 1, 1, 0, 0, 0));

    CONSTANT Num_7 : displayArr :=
    (
    (0, 0, 1, 1, 1, 1, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 1, 0, 0, 0),
    (0, 0, 0, 0, 0, 1, 0, 0, 0),
    (0, 0, 0, 0, 0, 1, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0));

    CONSTANT Num_8 : displayArr :=
    (
    (0, 0, 0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 1, 1, 1, 0, 0, 0));

    CONSTANT Num_9 : displayArr :=
    (
    (0, 0, 0, 1, 1, 0, 0, 0, 0),
    (0, 0, 1, 0, 0, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 1, 1, 1, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 1, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 1, 0, 0, 0, 0, 0));

    CONSTANT Win_score : displayArr :=
    (
    (0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 1, 0, 0, 0, 1, 1, 0),
    (0, 0, 1, 0, 1, 0, 1, 0, 0),
    (0, 0, 1, 0, 1, 0, 1, 0, 0),
    (0, 0, 1, 1, 0, 1, 1, 0, 0),
    (0, 0, 1, 1, 0, 1, 1, 0, 0),
    (0, 0, 1, 1, 0, 1, 1, 0, 0));

    CONSTANT Frenzy_symbol : displayArr :=
    (
    (0, 0, 0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 1, 0, 0, 0, 0, 0, 1, 0),
    (1, 0, 0, 1, 1, 1, 1, 0, 1),
    (1, 0, 0, 1, 0, 0, 0, 0, 1),
    (1, 0, 0, 1, 1, 1, 0, 0, 1),
    (0, 1, 0, 1, 0, 0, 0, 1, 0),
    (0, 0, 1, 1, 0, 0, 1, 0, 0),
    (0, 0, 0, 1, 1, 1, 0, 0, 0));

    CONSTANT Item_boot : displayArr :=
    (
    (0, 0, 0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 0, 1, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 1, 1, 1, 1, 0, 0),
    (0, 0, 1, 1, 1, 1, 1, 1, 0),
    (0, 0, 0, 1, 1, 1, 1, 0, 0));

    CONSTANT Item_booster : displayArr :=
    (
    (0, 0, 0, 0, 1, 0, 0, 0, 0),
    (0, 0, 0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 1, 1, 1, 1, 0, 0),
    (0, 1, 1, 1, 1, 1, 1, 1, 0),
    (0, 0, 0, 1, 1, 1, 0, 0, 0),
    (0, 0, 0, 1, 0, 1, 0, 0, 0),
    (0, 0, 0, 1, 0, 1, 0, 0, 0),
    (0, 0, 0, 1, 0, 1, 0, 0, 0),
    (0, 0, 0, 1, 1, 1, 0, 0, 0));

    CONSTANT Item_poison : displayArr :=
    (
    (0, 0, 0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 1, 1, 1, 1, 0, 0),
    (0, 0, 0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 1, 0, 0),
    (0, 1, 0, 1, 0, 1, 0, 1, 0),
    (0, 1, 0, 0, 1, 0, 0, 1, 0),
    (0, 1, 0, 1, 0, 1, 0, 1, 0),
    (0, 1, 1, 0, 0, 0, 1, 1, 0),
    (0, 0, 1, 1, 1, 1, 1, 0, 0));


    CONSTANT Winner : longdisplayArr :=
    -- Show text: "WINNER" on the screen
    (
    --1W                        2I                         3N                         4N                         5E                         6R
    (0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0),
    (0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0),
    (0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0),
    (0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0),
    (0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0),
    (0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0),
    (0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0),
    (0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1));
    --------- VGA CONSTANT START ---------
    -- row constants
    CONSTANT H_TOTAL : INTEGER := 1344 - 1;
    CONSTANT H_SYNC : INTEGER := 48 - 1;
    CONSTANT H_BACK : INTEGER := 240 - 1;
    -- Original value: start = 287, end = 1311
    CONSTANT H_START : INTEGER := 48 + 240 - 1;
    CONSTANT H_ACTIVE : INTEGER := 1024 - 1;
    CONSTANT H_END : INTEGER := 1344 - 32 - 1;
    CONSTANT H_FRONT : INTEGER := 32 - 1;

    -- column constants
    CONSTANT V_TOTAL : INTEGER := 625 - 1;
    CONSTANT V_SYNC : INTEGER := 3 - 1;
    CONSTANT V_BACK : INTEGER := 12 - 1;
    -- Original value: start = 14, end = 614
    CONSTANT V_START : INTEGER := 3 + 12 - 1;
    CONSTANT V_ACTIVE : INTEGER := 600 - 1;
    CONSTANT V_END : INTEGER := 625 - 10 - 1;
    CONSTANT V_FRONT : INTEGER := 10 - 1;
    SIGNAL hcount, vcount : INTEGER;

    --------- VGA CONSTANT END ---------

    -- Constant
    CONSTANT INIT_X : INTEGER := H_START + 505;
    CONSTANT INIT_Y : INTEGER := V_START + 300;
    CONSTANT BOARD_THICK : INTEGER := 5;
    CONSTANT INIT_PADDLE_X : INTEGER := H_START + 70;
    CONSTANT INIT_PADDLE_Y : INTEGER := V_START + 260;
    CONSTANT SCOREBOARD1_XSTART : INTEGER := H_START + 473;
    CONSTANT SCOREBOARD1_XEND : INTEGER := H_START + 500;
    CONSTANT SCOREBOARD1_YSTART : INTEGER := V_START + 23;
    CONSTANT SCOREBOARD1_YEND : INTEGER := V_START + 50;
    CONSTANT SCOREBOARD2_XSTART : INTEGER := H_START + 512 + 12;
    CONSTANT SCOREBOARD2_XEND : INTEGER := H_START + 512 + 12 + 27;
    CONSTANT SCOREBOARD2_YSTART : INTEGER := SCOREBOARD1_YSTART;
    CONSTANT SCOREBOARD2_YEND : INTEGER := SCOREBOARD1_YEND;
    CONSTANT WINNER_P1_XSTART : INTEGER := SCOREBOARD1_XSTART - 172;
    CONSTANT WINNER_P1_XEND : INTEGER := WINNER_P1_XSTART + 162;
    CONSTANT WINNER_P1_YSTART : INTEGER := SCOREBOARD1_YSTART;
    CONSTANT WINNER_P1_YEND : INTEGER := SCOREBOARD1_YEND;
    CONSTANT WINNER_P2_XSTART : INTEGER := SCOREBOARD2_XEND + 172;
    CONSTANT WINNER_P2_XEND : INTEGER := WINNER_P2_XSTART + 162;
    CONSTANT WINNER_P2_YSTART : INTEGER := SCOREBOARD1_YSTART;
    CONSTANT WINNER_P2_YEND : INTEGER := SCOREBOARD1_YEND;

    -- For item
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

    -- Ball configuration
    SIGNAL X_STEP : INTEGER := BALL_X_BASESTEP;
    SIGNAL Y_STEP : INTEGER := BALL_Y_BASESTEP;
    SIGNAL ball_x : INTEGER := INIT_X;
    SIGNAL ball_y : INTEGER := INIT_Y;
    SIGNAL ball_dx : INTEGER := X_STEP;
    SIGNAL ball_dy : INTEGER := Y_STEP;
    SIGNAL illusion_ball_trigger : STD_LOGIC := '0';
    SIGNAL illusion_ball_x : INTEGER;
    SIGNAL illusion_ball_y : INTEGER;

    -- Player1 paddle configuration
    SIGNAL p1_x : INTEGER := INIT_PADDLE_X;
    SIGNAL p1_y : INTEGER := INIT_PADDLE_Y;
    -- Player2 paddle configuration
    SIGNAL p2_x : INTEGER := INIT_PADDLE_X + 878;
    SIGNAL p2_y : INTEGER := INIT_PADDLE_Y;
    SIGNAL p2_real_x : INTEGER;
    SIGNAL p2_real_y : INTEGER;

    -- AI parameters
    SIGNAL ai_level_1_x : INTEGER := INIT_PADDLE_X + 878;
    SIGNAL ai_level_1_y : INTEGER := INIT_PADDLE_Y;
    SIGNAL ai_level_2_x : INTEGER := INIT_PADDLE_X + 878;
    SIGNAL ai_level_2_y : INTEGER := INIT_PADDLE_Y;
    SIGNAL ai_level_3_x : INTEGER := INIT_PADDLE_X + 878;
    SIGNAL ai_level_3_y : INTEGER := INIT_PADDLE_Y;
    SIGNAL ai_fatigue_x : INTEGER := INIT_PADDLE_X + 878;
    SIGNAL ai_fatigue_y : INTEGER := INIT_PADDLE_Y;
    SIGNAL ai_sd_x : INTEGER := INIT_PADDLE_X + 878;
    SIGNAL ai_sd_y : INTEGER := INIT_PADDLE_Y;

    -- Item pixels
    SIGNAL p1_item_x : INTEGER;
    SIGNAL p1_item_y : INTEGER;
    SIGNAL p2_item_x : INTEGER;
    SIGNAL p2_item_y : INTEGER;

BEGIN

    -- Import player
    player1_unit : player
    PORT MAP(
        clk_ball,
        player1_control_signal,
        PADDLE_SIZE,
        P1_PADDLE_LENGTH,
        p1_x,
        p1_y,
        p1_paddle_dx,
        p1_paddle_dy,
        is_frenzy,
        game_reset,
        is_ai,
        is_poison_p1,
        '0'
    );

    player2_unit : player
    PORT MAP(
        clk_ball,
        player2_control_signal,
        PADDLE_SIZE,
        P2_PADDLE_LENGTH,
        p2_x,
        p2_y,
        p2_paddle_dx,
        p2_paddle_dy,
        is_frenzy,
        game_reset,
        is_ai,
        is_poison_p2,
        '1'
    );

    ai_unit : ai
    PORT MAP(
        led,
        sys_clk,
        clk_ball,
        PADDLE_SIZE,
        P2_PADDLE_LENGTH,
        ai_level_1_x,
        ai_level_1_y,
        ai_level_2_x,
        ai_level_2_y,
        ai_level_3_x,
        ai_level_3_y,
        ai_fatigue_x,
        ai_fatigue_y,
        ai_sd_x,
        ai_sd_y,
        p2_paddle_dx,
        p2_paddle_dy,
        ball_x,
        ball_y,
        ball_dx,
        ball_dy,
        game_reset,
        is_ai,
        is_end,
        ai_state,
        player1_score,
        player2_score
    );

    ball_unit : ball
    PORT MAP(
        clk_ball,
        vib_1,
        vib_2,
        is_end,
        BALL_SIZE,
        ball_x,
        ball_y,
        ball_dx,
        ball_dy,
        illusion_ball_x,
        illusion_ball_y,
        ball_startx_offset,
        ball_starty_offset,
        BALL_X_BASESTEP,
        ILLUSION_BALL_X_BASESTEP,
        ILLUSION_BALL_Y_BASESTEP,
        PADDLE_SIZE,
        P1_PADDLE_LENGTH,
        P2_PADDLE_LENGTH,
        strong_hit_multiplier,
        weak_hit_multiplier,
        is_left_miss,
        is_right_miss,
        p1_x,
        p1_y,
        p2_real_x,
        p2_real_y,
        ai_state,
        is_ai,
        is_strong,
        is_weak,
        illusion_ball_trigger,
        player1_control_signal,
        player2_control_signal,
        pseudo_rand

    );

    item_unit : item_generator
    PORT MAP(
        clk_ball, clk_item,
        game_begin,
        p1_item_trigger,
        p2_item_trigger,
        PADDLE_SIZE,
        P1_PADDLE_LENGTH,
        P2_PADDLE_LENGTH,
        P1_PADDLE_DX,
        P2_PADDLE_DX,
        P1_PADDLE_DY,
        P2_PADDLE_DY,
        p1_x,
        p1_y,
        p2_real_x,
        p2_real_y,
        p1_item_x,
        p1_item_y,
        p2_item_x,
        p2_item_y,
        p1_item_ready,
        p2_item_ready,
        is_ai,
        is_frenzy,
        is_long_p1,
        is_long_p2,
        is_speed_p1,
        is_speed_p2,
        is_poison_p1,
        is_poison_p2,
        pseudo_rand
    );
    --------- VGA UTILITY START ---------
    -- horizontal counter in [0, H_TOTAL]
    pixel_count_proc : PROCESS (clk)
    BEGIN
        IF (rising_edge(clk))
            THEN
            IF (hcount = H_TOTAL)
                THEN
                hcount <= 0;
            ELSE
                hcount <= hcount + 1;
            END IF;
        END IF;
    END PROCESS pixel_count_proc;

    -- generate hsync in [0, H_SYNC)
    hsync_gen_proc : PROCESS (hcount)
    BEGIN
        IF (hcount <= H_SYNC)
            THEN
            hsync <= '1';
        ELSE
            hsync <= '0';
        END IF;
    END PROCESS hsync_gen_proc;

    -- vertical counter in [0, V_TOTAL]
    line_count_proc : PROCESS (clk)
    BEGIN
        IF (rising_edge(clk))
            THEN
            IF (hcount = H_TOTAL)
                THEN
                IF (vcount = V_TOTAL)
                    THEN
                    vcount <= 0;
                ELSE
                    vcount <= vcount + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS line_count_proc;

    -- generate vsync in [0, V_SYNC)
    vsync_gen_proc : PROCESS (hcount)
    BEGIN
        IF (vcount <= V_SYNC) THEN
            vsync <= '1';
        ELSE
            vsync <= '0';
        END IF;
    END PROCESS vsync_gen_proc;

    -- Up Board
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            -- Only render in a range to represent the board
            IF ((hcount >= H_START + 50 AND hcount < H_END - 600) AND
                (vcount >= V_START + 50 AND vcount < V_TOTAL - 600))
                THEN
                rendering_board_up <= '1';
            ELSIF ((hcount <= H_END - 50 AND hcount > H_START + 50)AND
                (vcount <= V_START + BOARD_THICK + 50 AND vcount > V_START + 50))
                THEN
                rendering_board_up <= '1';
            ELSE
                rendering_board_up <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Down Board
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            -- Only render in a range to represent the board
            IF ((hcount >= H_START + 50 AND hcount < H_END - 600) AND
                (vcount >= V_START + 50 + 500 AND vcount < V_TOTAL - 600))
                THEN
                rendering_board_down <= '1';
            ELSIF ((hcount <= H_END - 50 AND hcount > H_START + 50)AND
                (vcount <= V_START + BOARD_THICK + 50 + 500 AND vcount > V_START + 50 + 500))
                THEN
                rendering_board_down <= '1';
            ELSE
                rendering_board_down <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Middle Line
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            -- Only render in a range to represent the board
            IF (hcount >= H_START + 512 AND hcount < H_START + 512 + BOARD_THICK)
                THEN
                rendering_board_mid <= '1';
            ELSE
                rendering_board_mid <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Left Board
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            -- Only render in a range to represent the board
            IF ((hcount >= H_START + 50 AND hcount < H_START + 50 + BOARD_THICK) AND
                (vcount >= V_START + 51 AND vcount < V_TOTAL - 55))
                THEN
                rendering_board_left <= '1';
            ELSE
                rendering_board_left <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Right Board
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            -- Only render in a range to represent the board
            IF ((hcount >= H_END - 49 - BOARD_THICK AND hcount < H_END - 50) AND
                (vcount >= V_START + 51 AND vcount < V_TOTAL - 53))
                THEN
                rendering_board_right <= '1';
            ELSE
                rendering_board_right <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Score Board
    PROCESS (clk, player1_score, player2_score)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF ((hcount >= SCOREBOARD1_XSTART AND hcount < SCOREBOARD1_XEND) AND
                (vcount >= SCOREBOARD1_YSTART AND vcount < SCOREBOARD1_YEND))
                THEN
                CASE (player1_score) IS
                    WHEN 0 =>
                        IF (Num_0((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN 1 =>
                        IF (Num_1((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN 2 =>
                        IF (Num_2((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN 3 =>
                        IF (Num_3((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN 4 =>
                        IF (Num_4((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN 5 =>
                        IF (Num_5((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN 6 =>
                        IF (Num_6((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN 7 =>
                        IF (Num_7((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN 8 =>
                        IF (Num_8((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN 9 =>
                        IF (Num_9((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                            THEN
                            rendering_p1_scoreboard <= '1';
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                    WHEN OTHERS =>
                        IF player1_score > 9 THEN
                            IF (Win_score((vcount - SCOREBOARD1_YSTART)/3, (hcount - SCOREBOARD1_XSTART)/3) = 1)
                                THEN
                                rendering_p1_scoreboard <= '1';
                            ELSE
                                rendering_p1_scoreboard <= '0';
                            END IF;
                        ELSE
                            rendering_p1_scoreboard <= '0';
                        END IF;
                END CASE;
            ELSIF ((hcount >= SCOREBOARD2_XSTART AND hcount < SCOREBOARD2_XEND) AND
                (vcount >= SCOREBOARD2_YSTART AND vcount < SCOREBOARD2_YEND))
                THEN
                CASE (player2_score) IS
                    WHEN 0 =>
                        IF (Num_0((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN 1 =>
                        IF (Num_1((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN 2 =>
                        IF (Num_2((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN 3 =>
                        IF (Num_3((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN 4 =>
                        IF (Num_4((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN 5 =>
                        IF (Num_5((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN 6 =>
                        IF (Num_6((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN 7 =>
                        IF (Num_7((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN 8 =>
                        IF (Num_8((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN 9 =>
                        IF (Num_9((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                            THEN
                            rendering_p2_scoreboard <= '1';
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                    WHEN OTHERS =>
                        IF player2_score > 9 THEN
                            IF (Win_score((vcount - SCOREBOARD2_YSTART)/3, (hcount - SCOREBOARD2_XSTART)/3) = 1)
                                THEN
                                rendering_p2_scoreboard <= '1';
                            ELSE
                                rendering_p2_scoreboard <= '0';
                            END IF;
                        ELSE
                            rendering_p2_scoreboard <= '0';
                        END IF;
                END CASE;
            ELSE
                rendering_p1_scoreboard <= '0';
                rendering_p2_scoreboard <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Get pixels of the ball
    PROCESS (clk)
    BEGIN
        IF ((hcount >= H_START AND hcount < H_END) AND
            (vcount >= V_START AND vcount < V_TOTAL))
            THEN
            IF (ball_x <= hcount AND hcount < ball_x + BALL_SIZE AND
                ball_y < vcount AND vcount < ball_y + BALL_SIZE)
                THEN
                rendering_ball <= '1';
            ELSE
                rendering_ball <= '0';
            END IF;
        ELSE
            rendering_ball <= '0';
        END IF;
    END PROCESS;
    -- Get pixels of illusion ball
    PROCESS (clk, illusion_ball_trigger)
    BEGIN
        IF ((hcount >= H_START AND hcount < H_END) AND
            (vcount >= V_START AND vcount < V_TOTAL) AND
            (illusion_ball_trigger = '1')
            )
            THEN
            IF (illusion_ball_x <= hcount AND hcount < illusion_ball_x + BALL_SIZE AND
                illusion_ball_y < vcount AND vcount < illusion_ball_y + BALL_SIZE)
                THEN
                rendering_illusion_ball <= '1';
            ELSE
                rendering_illusion_ball <= '0';
            END IF;
        ELSE
            rendering_illusion_ball <= '0';
        END IF;
    END PROCESS;

    -- Get pixels of p1 paddle
    PROCESS (clk)
    BEGIN
        IF ((hcount >= H_START AND hcount < H_END) AND
            (vcount >= V_START AND vcount < V_TOTAL))
            THEN
            IF (p1_x <= hcount AND hcount < p1_x + PADDLE_SIZE AND
                p1_y < vcount AND vcount < p1_y + PADDLE_SIZE + P1_PADDLE_LENGTH)
                THEN
                rendering_p1_paddle <= '1';
            ELSE
                rendering_p1_paddle <= '0';
            END IF;
        ELSE
            rendering_p1_paddle <= '0';
        END IF;
    END PROCESS;

    -- Get pixels of p2 paddle
    PROCESS (clk, ai_state)
    BEGIN
        -- Assign back the x, y accordingly
        -- p2, ai, ai different lv
        IF (is_ai = '0') THEN
            p2_real_x <= p2_x;
            p2_real_y <= p2_y;
        ELSE
            CASE (ai_state) IS
                    -- Different ai lv
                WHEN 1 =>
                    p2_real_x <= ai_level_1_x;
                    p2_real_y <= ai_level_1_y;
                WHEN 2 =>
                    p2_real_x <= ai_level_2_x;
                    p2_real_y <= ai_level_2_y;
                WHEN 3 =>
                    p2_real_x <= ai_level_3_x;
                    p2_real_y <= ai_level_3_y;
                WHEN 4 =>
                    p2_real_x <= ai_fatigue_x;
                    p2_real_y <= ai_fatigue_y;
                WHEN 5 =>
                    p2_real_x <= ai_sd_x;
                    p2_real_y <= ai_sd_y;
                WHEN OTHERS =>
            END CASE;
        END IF;
        IF ((hcount >= H_START AND hcount < H_END) AND
            (vcount >= V_START AND vcount < V_TOTAL))
            THEN
            IF (p2_real_x <= hcount AND hcount < p2_real_x + PADDLE_SIZE AND
                p2_real_y < vcount AND vcount < p2_real_y + PADDLE_SIZE + P2_PADDLE_LENGTH)
                THEN
                rendering_p2_paddle <= '1';
            ELSE
                rendering_p2_paddle <= '0';
            END IF;
        ELSE
            rendering_p2_paddle <= '0';
        END IF;
    END PROCESS;

    -- Get pixels of showing winner message
    PROCESS (clk, player1_score, player2_score, is_winner)
    BEGIN
        IF (rising_edge(clk) AND is_winner = '1') THEN
            IF ((hcount >= WINNER_P1_XSTART AND hcount < WINNER_P1_XEND) AND
                (vcount >= WINNER_P1_YSTART AND vcount < WINNER_P1_YEND))
                THEN
                IF (Winner((vcount - WINNER_P1_YSTART)/3, (hcount - WINNER_P1_XSTART)/3) = 1 AND player1_score > 9)
                    THEN
                    rendering_winner <= '1';
                ELSE
                    rendering_winner <= '0';
                END IF;
            ELSIF ((hcount >= WINNER_P2_XSTART AND hcount < WINNER_P2_XEND) AND
                (vcount >= WINNER_P2_YSTART AND vcount < WINNER_P2_YEND))
                THEN
                IF (Winner((vcount - WINNER_P2_YSTART)/3, (hcount - WINNER_P2_XSTART)/3) = 1 AND player2_score > 9)
                    THEN
                    rendering_winner <= '1';
                ELSE
                    rendering_winner <= '0';
                END IF;
            ELSE
                rendering_winner <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Get pixels of frenzy symbol
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF(is_frenzy = '1') THEN
                IF ((hcount >= H_START + 50 AND hcount < H_START + 50 + 28) AND
                    (vcount >= WINNER_P1_YSTART AND vcount < WINNER_P1_YEND))

                    THEN
                    IF (Frenzy_symbol((vcount - WINNER_P1_YSTART)/3, (hcount - (H_START + 50))/3) = 1 )
                    THEN
                        rendering_frenzy <= '1';
                    ELSE
                        rendering_frenzy <= '0';
                    END IF;
                END IF;
            ELSE
                rendering_frenzy <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Get pixels of p1 item
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF(is_frenzy = '1' AND p1_item_ready = '1') THEN
                IF ((hcount >= p1_item_x AND hcount < p1_item_x + 27) AND
                    (vcount >= p1_item_y AND vcount < p1_item_y + 27))
                    THEN

                    CASE (p1_item_trigger) IS
                        -- Boot
                        WHEN 0 => 
                            IF (Item_boot((vcount - p1_item_y)/3, (hcount - (p1_item_x))/3) = 1 )
                            THEN
                                rendering_p1_item <= '1';
                            ELSE
                                rendering_p1_item <= '0';
                            END IF;

                        -- Booster
                        WHEN 1 =>
                            IF (Item_booster((vcount - p1_item_y)/3, (hcount - (p1_item_x))/3) = 1 )
                            THEN
                                rendering_p1_item <= '1';
                            ELSE
                                rendering_p1_item <= '0';
                            END IF;

                        -- Poison
                        WHEN 2 =>
                            IF (Item_poison((vcount - p1_item_y)/3, (hcount - (p1_item_x))/3) = 1 )
                            THEN
                                rendering_p1_item <= '1';
                            ELSE
                                rendering_p1_item <= '0';
                            END IF;

                        WHEN OTHERS =>
                            rendering_p1_item <= '0';
                    END CASE;
                END IF;
            ELSE
                rendering_p1_item <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Get pixels of p2 item
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF(is_frenzy = '1' AND p2_item_ready = '1') THEN
                IF ((hcount >= p2_item_x AND hcount < p2_item_x + 27) AND
                    (vcount >= p2_item_y AND vcount < p2_item_y + 27))
                    THEN

                    CASE (p2_item_trigger) IS
                        -- Boot
                        WHEN 0 => 
                            IF (Item_boot((vcount - p2_item_y)/3, (hcount - (p2_item_x))/3) = 1 )
                            THEN
                                rendering_p2_item <= '1';
                            ELSE
                                rendering_p2_item <= '0';
                            END IF;

                        -- Booster
                        WHEN 1 =>
                            IF (Item_booster((vcount - p2_item_y)/3, (hcount - (p2_item_x))/3) = 1 )
                            THEN
                                rendering_p2_item <= '1';
                            ELSE
                                rendering_p2_item <= '0';
                            END IF;

                        -- Poison
                        WHEN 2 =>
                            IF (Item_poison((vcount - p2_item_y)/3, (hcount - (p2_item_x))/3) = 1 )
                            THEN
                                rendering_p2_item <= '1';
                            ELSE
                                rendering_p2_item <= '0';
                            END IF;

                        WHEN OTHERS =>
                            rendering_p2_item <= '0';
                    END CASE;
                END IF;
            ELSE
                rendering_p2_item <= '0';
            END IF;
        END IF;
    END PROCESS;


END Behavioral;