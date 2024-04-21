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
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
        -- reset outputs
      o_pc <= (others => '0');
      o_WB <= (others => '0');
      o_stackControl <= (others => '0');
      o_memWrite <= '0';
      o_memRead <= '0';
      o_inputEnable <= '0';
      o_outputEnable <= '0';
      o_isImm <= '0';
      o_isProtect <= '0';
      o_isFree <= '0';
      o_isBranch <= '0';
      o_aluOP <= (others => '0');
      o_vRs1 <= (others => '0');
      o_vRs2 <= (others => '0');
      o_vImmediate <= (others => '0');
      o_aRs1 <= (others => '0');
      o_aRs2 <= (others => '0');
      o_aRd <= (others => '0');
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
      o_isBranch <= i_isBranch;
      o_aluOP <= i_aluOP;
      o_vRs1 <= i_vRs1;
      o_vRs2 <= i_vRs2;
      o_vImmediate <= i_vImmediate;
      o_aRs1 <= i_aRs1;
      o_aRs2 <= i_aRs2;
      o_aRd <= i_aRd;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE Behavioral;