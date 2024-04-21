LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ID_EX IS
  PORT (
    i_clk,i_reset,i_en : in std_logic := '0';
    -- Input control signals
    i_WB : in std_logic_vector(1 downto 0) := (others => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
    i_stackControl : in std_logic_vector(1 downto 0) := (others => '0'); --to determine what types of stack instructions is needed
    i_memWrite : in std_logic := '0'; --store
    i_memRead : in std_logic := '0'; --load
    i_isRti : in std_logic := '0';
    i_inputEnable : in std_logic := '0'; --on in
    i_outputEnable : in std_logic := '0'; --on out
    i_isImm : in std_logic := '0'; -- bit in instruction
    i_isProtect : in std_logic := '0';
    i_isFree : in std_logic := '0';
    i_isBranch : in std_logic := '0';
    -- Input signals from decode
    i_aluOP : in std_logic_vector(3 downto 0) := (others => '0');
    i_vRs1 : in std_logic_vector(31 downto 0) := (others => '0');
    i_vRs2 : in std_logic_vector(31 downto 0) := (others => '0');
    i_vImmediate : in std_logic_vector(31 downto 0) := (others => '0');
    i_aRs1 : in std_logic_vector(2 downto 0) := (others => '0');
    i_aRs2 : in std_logic_vector(2 downto 0) := (others => '0');
    i_aRd : in std_logic_vector(2 downto 0) := (others => '0');
    -- Input no-logic wires
    i_pc : out std_logic_vector(31 downto 0) := (others => '0'); 
    -- Output ### ADD SEMI-COLON ABOVE
    o_WB : out std_logic_vector(1 downto 0) := (others => '0');
    o_stackControl : out std_logic_vector(1 downto 0) := (others => '0');
    o_memWrite : out std_logic := '0';
    o_memRead : out std_logic := '0'; 
    o_isRti : out std_logic := '0';
    o_inputEnable : out std_logic := '0';
    o_outputEnable : out std_logic := '0'; 
    o_isImm : out std_logic := '0'; 
    o_isProtect : out std_logic := '0';
    o_isFree : out std_logic := '0';
    o_isBranch : out std_logic := '0';
    o_aluOP : out std_logic_vector(3 downto 0) := (others => '0');
    o_vRs1 : out std_logic_vector(31 downto 0) := (others => '0');
    o_vRs2 : out std_logic_vector(31 downto 0) := (others => '0');
    o_vImmediate : out std_logic_vector(31 downto 0) := (others => '0');
    o_aRs1 : out std_logic_vector(2 downto 0) := (others => '0');
    o_aRs2 : out std_logic_vector(2 downto 0) := (others => '0');
    o_aRd : out std_logic_vector(2 downto 0) := (others => '0');
    -- Input no-logic wires
    o_pc : out std_logic_vector(31 downto 0) := (others => '0') -- ### ADD SEMI-COLON

  );
END ENTITY ID_EX;

ARCHITECTURE Behavioral OF ID_EX IS
    signal s_WB : std_logic_vector(1 downto 0) := (others => '0');
    signal s_stackControl : std_logic_vector(1 downto 0) := (others => '0');
    signal s_memWrite : std_logic := '0';
    signal s_memRead : std_logic := '0'; 
    signal s_isRti : std_logic := '0';
    signal s_inputEnable : std_logic := '0';
    signal s_outputEnable : std_logic := '0'; 
    signal s_isImm : std_logic := '0'; 
    signal s_isProtect : std_logic := '0';
    signal s_isFree : std_logic := '0';
    signal s_isBranch : std_logic := '0';
    signal s_aluOP : std_logic_vector(3 downto 0) := (others => '0');
    signal s_vRs1 : std_logic_vector(31 downto 0) := (others => '0');
    signal s_vRs2 : std_logic_vector(31 downto 0) := (others => '0');
    signal s_vImmediate : std_logic_vector(31 downto 0) := (others => '0');
    signal s_aRs1 : std_logic_vector(2 downto 0) := (others => '0');
    signal s_aRs2 : std_logic_vector(2 downto 0) := (others => '0');
    signal s_aRd : std_logic_vector(2 downto 0) := (others => '0');
    signal s_pc : std_logic_vector(31 downto 0) := (others => '0'); 
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
        -- reset outputs
    ELSIF rising_edge(i_clk) THEN
      IF i_en = '1' THEN
      s_pc <= i_pc; 
      -- Output ### ADD SEMI-COLON ABOVE
      s_WB <= i_WB;
      s_stackControl <= i_stackControl;
      s_memWrite <= i_memWrite;
      s_memRead <= i_memRead; 
      s_isRti <= i_isRti;
      s_inputEnable <= i_inputEnable;
      s_outputEnable <= i_outputEnable; 
      s_isImm <= i_isImm;
      s_isProtect <= i_isProtect;
      s_isFree <= i_isFree;
      s_isBranch <= i_isBranch;
      s_aluOP <= i_aluOP;
      s_vRs1 <= i_vRs1;
      s_vRs2 <= i_vRs2;
      s_vImmediate <= i_vImmediate;
      s_aRs1 <= i_aRs1;
      s_aRs2 <= i_aRs2;
      s_aRd <= i_aRd;
      END IF;
    END IF;
  END PROCESS;
  o_pc <= s_pc; 
  o_WB <= s_WB;
  o_stackControl <= s_stackControl;
  o_memWrite <= s_memWrite;
  o_memRead <= s_memRead; 
  o_isRti <= s_isRti;
  o_inputEnable <= s_inputEnable;
  o_outputEnable <= s_outputEnable; 
  o_isImm <= s_isImm;
  o_isProtect <= s_isProtect;
  o_isFree <= s_isFree;
  o_isBranch <= s_isBranch;
  o_aluOP <= s_aluOP;
  o_vRs1 <= s_vRs1;
  o_vRs2 <= s_vRs2;
  o_vImmediate <= s_vImmediate;
  o_aRs1 <= s_aRs1;
  o_aRs2 <= s_aRs2;
  o_aRd <= s_aRd;
END ARCHITECTURE Behavioral;