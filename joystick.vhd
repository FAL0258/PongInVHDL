--------------------------------------------------------------------------------
--
--   FileName:         pmod_joystick.vhd
--   Dependencies:     spi_master.vhd
--   Design Software:  Quartus Prime Version 17.0.0 Build 595 SJ Lite Edition
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 02/24/2023 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY joystick IS
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
  --    trigger_button  : OUT    STD_LOGIC;                     --trigger button status
  --    center_button   : OUT    STD_LOGIC;
  --    led0            : OUT    STD_LOGIC;
  --    led1            : OUT    STD_LOGIC;
  --    led2            : OUT    STD_LOGIC;
  --    led3            : OUT    STD_LOGIC;
  --    led4            : OUT    STD_LOGIC;
  --    led5            : OUT    STD_LOGIC;
  --    led6            : OUT    STD_LOGIC;
  --    led7            : OUT    STD_LOGIC);                    --center button status

  --    sel: buffer STD_LOGIC := '0';
  --    ssd: out STD_LOGIC_VECTOR (6 downto 0));
END joystick;

ARCHITECTURE behavior OF joystick IS
  TYPE machine IS(start, initiate_transaction, byte_transact, byte_pause, output_results); --needed states
  SIGNAL state : machine := start; --state machine
  SIGNAL spi_ena : STD_LOGIC; --enable for SPI bus
  SIGNAL spi_rx : STD_LOGIC_VECTOR(7 DOWNTO 0); --latest data byte received by SPI
  SIGNAL spi_rx_data : STD_LOGIC_VECTOR(17 DOWNTO 0); --latest data packet received by SPI
  SIGNAL spi_busy : STD_LOGIC; --busy signal from spi bus
  SIGNAL x_position : STD_LOGIC_VECTOR(7 DOWNTO 0); --joystick x-axis position
  SIGNAL y_position : STD_LOGIC_VECTOR(7 DOWNTO 0); --joystick y-axis position
  SIGNAL reset_n : STD_LOGIC; --active low reset

  --declare SPI Master component
  COMPONENT spi_master IS
    GENERIC (
      slaves : INTEGER := 1; --number of spi slaves
      d_width : INTEGER := 8); --data bus width
    PORT (
      clock : IN STD_LOGIC; --system clock
      reset_n : IN STD_LOGIC; --asynchronous reset
      enable : IN STD_LOGIC; --initiate transaction
      cpol : IN STD_LOGIC; --spi clock polarity
      cpha : IN STD_LOGIC; --spi clock phase
      cont : IN STD_LOGIC; --continuous mode command
      clk_div : IN INTEGER; --system clock cycles per 1/2 period of sclk
      addr : IN INTEGER; --address of slave
      tx_data : IN STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0); --data to transmit
      miso : IN STD_LOGIC; --master in, slave out
      sclk : BUFFER STD_LOGIC; --spi clock
      ss_n : BUFFER STD_LOGIC_VECTOR(slaves - 1 DOWNTO 0); --slave select
      mosi : OUT STD_LOGIC; --master out, slave in
      busy : OUT STD_LOGIC; --busy / data ready signal
      rx_data : OUT STD_LOGIC_VECTOR(d_width - 1 DOWNTO 0)); --data received
  END COMPONENT spi_master;

  COMPONENT clk_div IS
    GENERIC (N : INTEGER);
    PORT (
      clk_in : IN STD_LOGIC;
      clk_out : OUT STD_LOGIC
    );
  END COMPONENT;
  -- Add any signal if necessary
  SIGNAL digit : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL clk100hz : STD_LOGIC;
BEGIN

  reset_n <= '1';

  --instantiate and configure the SPI Master component
  spi_master_0 : spi_master
  GENERIC MAP(slaves => 1, d_width => 8)
  PORT MAP(
    clock => clk, reset_n => reset_n, enable => spi_ena, cpol => '0',
    cpha => '0', cont => '0', clk_div => clk_freq/2, addr => 0,
    tx_data => "11000000", miso => miso, sclk => sclk, ss_n => OPEN,
    mosi => mosi, busy => spi_busy, rx_data => spi_rx);

  PROCESS (clk, reset_n)
    VARIABLE count : INTEGER RANGE 0 TO clk_freq * 100000 := 0; --counter
    VARIABLE byte : INTEGER RANGE 0 TO 6 := 0; --counts the packet bytes during transactions
  BEGIN

    IF (reset_n = '0') THEN --reset activated
      cs_n <= '1'; --clear chip select
      spi_ena <= '0'; --clear SPI component enable
      count := 0; --clear counter
      byte := 0; --clear byte counter
      x_position <= (OTHERS => '0'); --clear joystick x-axis position data
      y_position <= (OTHERS => '0'); --clear joystick y-axis position data
      --      trigger_button <= '0';                   --clear joystick trigger button data
      center_button <= '0'; --clear joystick center button data
      state <= start; --restart state machine
    ELSIF (clk'EVENT AND clk = '1') THEN --rising edge of system clock

      CASE state IS --state machine

          --entry state, give joystick 100ms to power up before communicating
        WHEN start =>
          IF (count < clk_freq * 100000) THEN --100ms not yet reached
            count := count + 1; --increment counter
          ELSE --100ms has elapsed
            count := 0; --clear counter
            state <= initiate_transaction; --advance to initiate transaction with joystick
          END IF;

          --initiate transaction with joystick and wait 15us before starting first byte
        WHEN initiate_transaction =>
          cs_n <= '0'; --initiate pmod chip select
          IF (count < clk_freq * 15) THEN --15us not yet reached
            count := count + 1; --increment counter
          ELSE --15us reached
            count := 0; --clear counter
            state <= byte_transact; --advance to start single byte data transfer
          END IF;

          --initiate SPI single byte data transfer with joystick 
        WHEN byte_transact =>
          IF (spi_busy = '0') THEN --SPI master bus is available
            spi_ena <= '1'; --initiate transaction
          ELSE --transaction underway
            spi_ena <= '0'; --clear SPI master enable
            state <= byte_pause; --advance to finishing transaction and pausing between bytes
          END IF;

          --complete the byte transaction and pause 10us between bytes   
        WHEN byte_pause =>
          IF (spi_busy = '0') THEN --SPI transaction is complete
            IF (byte < 6) THEN --not the last byte
              IF (byte = 4) THEN --5th data byte in packet
                spi_rx_data(17 DOWNTO 16) <= spi_rx(1 DOWNTO 0); --get button status data
              END IF;
              IF (byte = 5) THEN --6th data byte in packet
                spi_rx_data(7 DOWNTO 0) <= spi_rx; --get x-axis position data
              END IF;
              IF (count < clk_freq * 10) THEN --10us not yet reached
                count := count + 1; --increment clock counter
              ELSE --10us has elapsed
                count := 0; --clear counter
                byte := byte + 1; --advance the byte counter
                state <= byte_transact; --initiate next single byte data transfer 
              END IF;
            ELSE --last data byte in packet
              spi_rx_data(15 DOWNTO 8) <= spi_rx; --get y-axis position data
              byte := 0; --clear data byte counter for next transaction
              cs_n <= '1'; --clear chip select
              state <= output_results; --advance to outputting results
            END IF;
          END IF;

          --output results and wait 1ms for next transaction
        WHEN output_results =>
          x_position(7 DOWNTO 0) <= spi_rx_data(7 DOWNTO 0); --output joystick x-axis position
          y_position(7 DOWNTO 0) <= spi_rx_data(15 DOWNTO 8); --output joystick y-axis position
          --          trigger_button <= spi_rx_data(17);                   --output joystick trigger button status
          center_button <= spi_rx_data(16); --output joystick center button status
          IF (count < clk_freq * 1000) THEN --1ms not yet reached
            count := count + 1; --increment clock counter
          ELSE --1ms has elapsed
            count := 0; --clear counter
            state <= initiate_transaction; --initiate new transaction 
          END IF;

          --default to start state
        WHEN OTHERS =>
          state <= start;

      END CASE;
    END IF;
  END PROCESS;

  PROCESS (x_position, y_position)
  BEGIN
    IF ((x_position > "01000000") AND (x_position < "11000000") AND (y_position >= "00000000") AND (y_position <= "01000000")) THEN
      direction <= "1000"; -- UP
    ELSIF ((x_position > "01000000") AND (x_position < "11000000") AND (y_position >= "1111100") AND (y_position <= "11111111")) THEN
      direction <= "0100"; -- DOWN
    ELSIF ((x_position >= "00000000") AND (x_position <= "01000000") AND (y_position > "01000000") AND (y_position < "11000000")) THEN
      direction <= "0010"; -- LEFT
    ELSIF ((x_position >= "11111000") AND (x_position <= "11111111") AND (y_position > "01000000") AND (y_position < "11000000")) THEN
      direction <= "0001"; -- RIGHT
    ELSE
      direction <= "0000"; -- origin
    END IF;
  END PROCESS;
  --  process(x_position) begin
  --        IF (x_position(0) = '1') THEN
  --            led0 <= '1';
  --        ELSE
  --            led0 <= '0';
  --        END if;

  --        IF (x_position(1) = '1') THEN
  --            led1 <= '1';
  --        ELSE
  --            led1 <= '0';
  --        END if;

  --        IF (x_position(2) = '1') THEN
  --            led2 <= '1';
  --        ELSE
  --            led2 <= '0';
  --        END if;

  --        IF (x_position(3) = '1') THEN
  --            led3 <= '1';
  --        ELSE
  --            led3 <= '0';
  --        END if;

  --        IF (x_position(4) = '1') THEN
  --            led4 <= '1';
  --        ELSE
  --             led4 <= '0';
  --        END if;

  --        IF (x_position(5) = '1') THEN
  --            led5 <= '1';
  --        ELSE
  --             led5 <= '0';
  --        END if;

  --        IF (x_position(6) = '1') THEN
  --            led6 <= '1';
  --        ELSE
  --            led6 <= '0';
  --        END if;

  --        IF (x_position(7) = '1') THEN
  --            led7 <= '1';
  --        ELSE
  --            led7 <= '0';
  --        END if;

  --    end process;
  --  process(digit) begin
  --          case digit is
  --              when "0000" => ssd <= "1111110";    -- 0x0
  --              when "0001" => ssd <= "0110000";    -- 0x1
  --              when "0010" => ssd <= "1101101";    -- 0x2
  --              when "0011" => ssd <= "1111001";    -- 0x3
  --              when "0100" => ssd <= "0110011";    -- 0x4
  --              when "0101" => ssd <= "1011011";    -- 0x5
  --              when "0110" => ssd <= "1011111";    -- 0x6
  --              when "0111" => ssd <= "1110000";    -- 0x7
  --              when "1000" => ssd <= "1111111";    -- 0x8
  --              when "1001" => ssd <= "1111011";    -- 0x9
  --              when "1010" => ssd <= "1110111";    -- 0xA
  --              when "1011" => ssd <= "0011111";    -- 0xb (lowercase)
  --              when "1100" => ssd <= "1001110";    -- 0xC
  --              when "1101" => ssd <= "0111101";    -- 0xd (lowercase)
  --              when "1110" => ssd <= "1001111";    -- 0xE
  --              when "1111" => ssd <= "1000111";    -- 0xF
  --              when others => ssd <= "0000000";
  --          end case;
  --  end process;

  -- TODO-5 : Port map the clk_div component (100MHz --> 100Hz)
  --      u_clk100hz : clk_div generic map(N => 500000)
  --      port map(clk, clk100hz);

  -- TODO-6: Time-multiplexing (Create as many process as you want, OR use both sequential and combinational statement)
  --      digit <= data_in(3 downto 0);
  --      process(clk100hz)
  --      begin
  --          if (rising_edge(clk100hz)) then
  --              sel <= NOT sel;
  --              if (sel = '0') then
  --                  digit <= x_position;
  --              else
  --                  digit <= y_position;
  --              end if;
  --          end if; 
  --      end process;
END behavior;