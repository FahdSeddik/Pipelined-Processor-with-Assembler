LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEM_WB IS
  PORT (
    -- inputs
    i_clk : IN STD_LOGIC := '0';
    i_reset : IN STD_LOGIC := '0'; -- reset signal
    i_en : IN STD_LOGIC := '0';
    i_flush : IN STD_LOGIC := '0';
    i_memRead : IN STD_LOGIC;
    i_writeBack : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    i_readData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_rdstAddr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    i_rs2Addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    i_rs2Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- outputs
    o_memRead : OUT STD_LOGIC;
    o_writeBack : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    o_readData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_rdstAddr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_rs2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_rs2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END ENTITY MEM_WB;

ARCHITECTURE Behavioral OF MEM_WB IS
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
      -- reset all the registers
      o_memRead <= '0';
      o_writeBack <= (OTHERS => '0');
      o_readData <= (OTHERS => '0');
      o_result <= (OTHERS => '0');
      o_rdstAddr <= (OTHERS => '0');
      o_rs2Addr <= (OTHERS => '0');
      o_rs2Data <= (OTHERS => '0');
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