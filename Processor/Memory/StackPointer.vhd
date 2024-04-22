LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

ENTITY StackPointer IS
    PORT( 
        i_clk: IN std_logic;
        i_rst: IN std_logic;
        i_push: IN std_logic;
        i_pop: IN std_logic;
        o_q : OUT std_logic_vector(31 DOWNTO 0)
    );
END StackPointer;

ARCHITECTURE SP OF StackPointer IS
BEGIN
    PROCESS (i_clk, i_rst)
    BEGIN
        IF i_rst = '1' THEN
            -- initial value of SP is (2^12-1)
            o_q <= x"00000FFD";
        ELSIF rising_edge(i_clk) THEN
            IF i_push = '1' THEN
                o_q <= o_q - 2;
            ELSIF i_pop = '1' THEN
                o_q <= o_q + 2;
            END IF;
        END IF;
    END PROCESS;
END SP;
