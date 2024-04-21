LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IF_ID IS
    PORT (
        -- inputs
        i_clk : IN STD_LOGIC := '0';
        i_reset : IN STD_LOGIC := '0'; -- reset signal
        i_en : IN STD_LOGIC := '0';
        i_memRead : IN std_logic;
        i_writeBack : IN std_logic_vector(1 downto 0);
        i_readData : IN std_logic_vector(31 downto 0);
        i_result : IN std_logic_vector(31 downto 0);
        i_rdstAddr : IN std_logic_vector(2 downto 0);
        i_rs2Addr : IN std_logic_vector(2 downto 0);
        i_rs2Data : IN std_logic_vector(31 downto 0);
        -- outputs
        o_memRead : OUT std_logic;
        o_writeBack : OUT std_logic_vector(1 downto 0);
        o_readData : OUT std_logic_vector(31 downto 0);
        o_result : OUT std_logic_vector(31 downto 0);
        o_rdstAddr : OUT std_logic_vector(2 downto 0);
        o_rs2Addr : OUT std_logic_vector(2 downto 0);
        o_rs2Data : OUT std_logic_vector(31 downto 0)  
    );
END ENTITY IF_ID;

ARCHITECTURE Behavioral OF IF_ID IS
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
        -- reset all the registers
        o_memRead <= '0';
        o_writeBack <= '0';
        o_readData <= '0';
        o_result <= '0';
        o_rdstAddr <= '0';
        o_rs2Addr <= '0';
        o_rs2Data <= '0';
    ELSIF rising_edge(i_clk) THEN
        IF i_en = '1' THEN 
            -- if enable is high
            -- assign the inputs to the outputs
            o_memRead <= i_memRead;
            o_writeBack <= i_writeBack;
            o_readData <= i_readData;
            o_result <= i_result;
            o_rdstAddr <= i_rdstAddr;
            o_rs2Addr <= i_rs2Addr;
            o_rs2Data <= i_rs2Data;
        END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE Behavioral;