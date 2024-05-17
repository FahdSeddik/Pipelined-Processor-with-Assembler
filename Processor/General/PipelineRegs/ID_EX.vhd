LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ID_EX IS
  PORT (
    i_clk, i_reset, i_en, i_flush : IN STD_LOGIC := '0';
    -- Input control signals
    i_WB : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
    i_stackControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); --to determine what types of stack instructions is needed
    i_memWrite : IN STD_LOGIC := '0'; --store
    i_memRead : IN STD_LOGIC := '0'; --load
    i_inputEnable : IN STD_LOGIC := '0'; --on in
    i_outputEnable : IN STD_LOGIC := '0'; --on out
    i_isImm : IN STD_LOGIC := '0'; -- bit in instruction
    i_isProtect : IN STD_LOGIC := '0';
    i_isFree : IN STD_LOGIC := '0';
    i_branchControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    -- Input signals from decode
    i_branchPredict : IN STD_LOGIC := '0';
    i_aluOP : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    i_vRs1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_vRs2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_vImmediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_aRs1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    i_aRs2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    i_aRd : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    -- Input no-logic wires
    i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    -- Output ### ADD SEMI-COLON ABOVE
    o_bitpredict : OUT STD_LOGIC := '0';
    o_WB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    o_stackControl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    o_memWrite : OUT STD_LOGIC := '0';
    o_memRead : OUT STD_LOGIC := '0';
    o_inputEnable : OUT STD_LOGIC := '0';
    o_outputEnable : OUT STD_LOGIC := '0';
    o_isImm : OUT STD_LOGIC := '0';
    o_isProtect : OUT STD_LOGIC := '0';
    o_isFree : OUT STD_LOGIC := '0';
    o_branchControl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    o_aluOP : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    o_vRs1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    o_vRs2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    o_vImmediate : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    o_aRs1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    o_aRs2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    o_aRd : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    -- Input no-logic wires
    o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
  );
END ENTITY ID_EX;

ARCHITECTURE Behavioral OF ID_EX IS
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
      -- reset outputs
      o_pc <= (OTHERS => '0');
      o_WB <= (OTHERS => '0');
      o_stackControl <= (OTHERS => '0');
      o_memWrite <= '0';
      o_memRead <= '0';
      o_inputEnable <= '0';
      o_outputEnable <= '0';
      o_isImm <= '0';
      o_isProtect <= '0';
      o_isFree <= '0';
      o_branchControl <= (OTHERS => '0');
      o_aluOP <= (OTHERS => '0');
      o_vRs1 <= (OTHERS => '0');
      o_vRs2 <= (OTHERS => '0');
      o_vImmediate <= (OTHERS => '0');
      o_aRs1 <= (OTHERS => '0');
      o_aRs2 <= (OTHERS => '0');
      o_aRd <= (OTHERS => '0');
      o_bitpredict <= '0';
    ELSIF rising_edge(i_clk) THEN
      IF i_en = '1' THEN
        o_pc <= i_pc;
        -- Output ### ADD SEMI-COLON ABOVE
        o_WB <= i_WB;
        o_stackControl <= i_stackControl;
        o_memWrite <= i_memWrite;
        o_memRead <= i_memRead;
        o_inputEnable <= i_inputEnable;
        o_outputEnable <= i_outputEnable;
        o_isImm <= i_isImm;
        o_isProtect <= i_isProtect;
        o_isFree <= i_isFree;
        o_branchControl <= o_branchControl;
        o_aluOP <= i_aluOP;
        o_vRs1 <= i_vRs1;
        o_vRs2 <= i_vRs2;
        o_vImmediate <= i_vImmediate;
        o_aRs1 <= i_aRs1;
        o_aRs2 <= i_aRs2;
        o_aRd <= i_aRd;
        o_bitpredict <= i_branchPredict;
      END IF;
      IF i_flush = '1' THEN
        o_pc <= (OTHERS => '0');
        o_WB <= (OTHERS => '0');
        o_stackControl <= (OTHERS => '0');
        o_memWrite <= '0';
        o_memRead <= '0';
        o_inputEnable <= '0';
        o_outputEnable <= '0';
        o_isImm <= '0';
        o_isProtect <= '0';
        o_isFree <= '0';
        o_branchControl <= (OTHERS => '0');
        o_aluOP <= (OTHERS => '0');
        o_vRs1 <= (OTHERS => '0');
        o_vRs2 <= (OTHERS => '0');
        o_vImmediate <= (OTHERS => '0');
        o_aRs1 <= (OTHERS => '0');
        o_aRs2 <= (OTHERS => '0');
        o_aRd <= (OTHERS => '0');
        o_bitpredict <= '0';
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE Behavioral;