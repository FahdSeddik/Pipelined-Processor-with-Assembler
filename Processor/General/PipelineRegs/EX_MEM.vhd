LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY EX_MEM IS
  PORT (
    i_clk, i_reset, i_en, i_flush : IN STD_LOGIC := '0';
    -- Input control signals
    i_WB : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
    i_stackControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); --to determine what types of stack instructions is needed
    i_memWrite : IN STD_LOGIC := '0'; --store
    i_memRead : IN STD_LOGIC := '0'; --load
    i_isProtect : IN STD_LOGIC := '0';
    i_isFree : IN STD_LOGIC := '0';
    -- Input data signals
    i_aluResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_vRs2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_aRd : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    i_aRs2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_flag : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    --output signals
    o_memRead : OUT STD_LOGIC;
    o_memWrite : OUT STD_LOGIC;
    o_WB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- i_writeEnable[1]->normal i_writeEnable[0]->on if swap
    o_isProtect : OUT STD_LOGIC;
    o_isFree : OUT STD_LOGIC;
    o_stackControl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    -- data
    o_aluResult : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU result
    o_vRs2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_aRd : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_aRs2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_flag : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END ENTITY EX_MEM;
ARCHITECTURE imp OF EX_MEM IS
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
      o_WB <= (OTHERS => '0');
      o_stackControl <= (OTHERS => '0');
      o_memWrite <= '0';
      o_memRead <= '0';
      o_isProtect <= '0';
      o_isFree <= '0';
      o_aluResult <= (OTHERS => '0');
      o_vRs2 <= (OTHERS => '0');
      o_aRd <= (OTHERS => '0');
      o_aRs2 <= (OTHERS => '0');
      o_pc <= (OTHERS => '0');
      o_flag <= (OTHERS => '0');
    ELSIF rising_edge(i_clk) THEN
      IF i_en = '1' THEN
        o_WB <= i_WB;
        o_stackControl <= i_stackControl;
        o_memWrite <= i_memWrite;
        o_memRead <= i_memRead;
        o_isProtect <= i_isProtect;
        o_isFree <= i_isFree;
        o_aluResult <= i_aluResult;
        o_vRs2 <= i_vRs2;
        o_aRd <= i_aRd;
        o_aRs2 <= i_aRs2;
        o_pc <= i_pc;
        o_flag <= i_flag;
      END IF;
      IF i_flush = '1' THEN
        o_WB <= (OTHERS => '0');
        o_stackControl <= (OTHERS => '0');
        o_memWrite <= '0';
        o_memRead <= '0';
        o_isProtect <= '0';
        o_isFree <= '0';
        o_aluResult <= (OTHERS => '0');
        o_vRs2 <= (OTHERS => '0');
        o_aRd <= (OTHERS => '0');
        o_aRs2 <= (OTHERS => '0');
        o_pc <= (OTHERS => '0');
        o_flag <= (OTHERS => '0');
      END IF;
    END IF;
  END PROCESS;
  --set the outputs u need
END ARCHITECTURE imp;