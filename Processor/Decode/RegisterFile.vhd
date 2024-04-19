LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY REGISTER_FILE IS
PORT(
i_clk : IN std_logic;
i_reset : IN std_logic;
i_we0 : IN std_logic;
i_we1 : IN std_logic;
i_rAddress0 : IN std_logic_vector(2 downto 0);
i_rAddress1 : IN std_logic_vector(2 downto 0);
i_wAddress0 : IN std_logic_vector(2 downto 0);
i_wAddress1 : IN std_logic_vector(2 downto 0);
i_wData0 : IN std_logic_vector(31 downto 0);
i_wData1 : IN std_logic_vector(31 downto 0);
-- Output
o_rData0 : OUT std_logic_vector(31 downto 0);
o_rData1 : OUT std_logic_vector(31 downto 0)
);
END ENTITY;

ARCHITECTURE syncrama OF REGISTER_FILE IS

TYPE ram_type IS ARRAY(0 TO 7) OF std_logic_vector(31 DOWNTO 0);
SIGNAL ram : ram_type ;

BEGIN
PROCESS(i_clk, i_wData0, i_wData1, i_reset, i_wAddress0, i_wAddress1, i_we0, i_we1) IS BEGIN
    IF i_reset THEN
        ram <= (others => (others => '0'));
    ELSIF rising_edge(i_clk) THEN
        IF i_we0 = '1' THEN
            ram(to_integer(unsigned(i_wAddress0))) <= i_wData0;
        END IF;
        IF i_we1 = '1' THEN
            ram(to_integer(unsigned(i_wAddress1))) <= i_wData1;
        END IF;
    ELSIF falling_edge(i_clk) THEN
        o_rData0 <= ram(to_integer(unsigned(i_rAddress0)));
        o_rData1 <= ram(to_integer(unsigned(i_rAddress1)));
    END IF;
END PROCESS;


END ARCHITECTURE;
