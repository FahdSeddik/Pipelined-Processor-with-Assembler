LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY REGISTER_FILE IS
    PORT (
        i_clk : IN STD_LOGIC;
        i_reset : IN STD_LOGIC;
        i_we0 : IN STD_LOGIC;
        i_we1 : IN STD_LOGIC;
        i_rAddress0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        i_rAddress1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        i_wAddress0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        i_wAddress1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        i_wData0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_wData1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- Output
        o_rData0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_rData1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE syncrama OF REGISTER_FILE IS

    TYPE ram_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ram : ram_type;

BEGIN
    PROCESS (i_clk, i_wData0, i_wData1, i_reset, i_wAddress0, i_wAddress1, i_we0, i_we1) IS BEGIN
        IF i_reset THEN
            ram <= (OTHERS => (OTHERS => '0'));
        ELSIF falling_edge(i_clk) THEN
            IF i_we0 = '1' THEN
                ram(to_integer(unsigned(i_wAddress0))) <= i_wData0;
            END IF;
            IF i_we1 = '1' THEN
                ram(to_integer(unsigned(i_wAddress1))) <= i_wData1;
            END IF;
        END IF;
    END PROCESS;
    o_rData0 <= ram(to_integer(unsigned(i_rAddress0)));
    o_rData1 <= ram(to_integer(unsigned(i_rAddress1)));
END ARCHITECTURE;