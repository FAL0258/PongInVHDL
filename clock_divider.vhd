LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY clock_divider IS
    GENERIC (N : INTEGER);
    PORT (
        CLK_IN : IN STD_LOGIC;
        CLK_OUT : OUT STD_LOGIC
    );
END clock_divider;

ARCHITECTURE Behavioral OF clock_divider IS
    SIGNAL counter : INTEGER := 0;
    SIGNAL sig : STD_LOGIC := '0';
BEGIN
    CLK_OUT <= sig;

    PROCESS (CLK_IN)
    BEGIN
        IF (rising_edge(CLK_IN)) THEN
            IF (counter = N - 1) THEN
                sig <= NOT sig;
                counter <= 0;
            ELSE
                counter <= counter + 1;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;