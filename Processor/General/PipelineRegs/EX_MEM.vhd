LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY EX_MEM IS
  PORT (
    i_clk,i_reset,i_en : in std_logic := '0';
    -- Input control signals
    i_WB : in std_logic_vector(1 downto 0) := (others => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
    i_stackControl : in std_logic_vector(1 downto 0) := (others => '0'); --to determine what types of stack instructions is needed
    i_memWrite : in std_logic := '0'; --store
    i_memRead : in std_logic := '0'; --load
    i_isRti : in std_logic := '0';
    i_isProtect : in std_logic := '0';
    i_isFree : in std_logic := '0';
    -- Input data signals
    i_aluResult : in std_logic_vector(31 downto 0) := (others => '0');
    i_vRs2 : in std_logic_vector(31 downto 0) := (others => '0');
    i_aRd : in std_logic_vector(2 downto 0) := (others => '0');
    i_aRs2 : in std_logic_vector(2 downto 0) := (others => '0');
    i_pc : in std_logic_vector(31 downto 0) := (others => '0')
    );
    END ENTITY EX_MEM;
ARCHITECTURE imp OF EX_MEM IS
    signal s_WB :  std_logic_vector(1 downto 0) := (others => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
    signal s_stackControl :  std_logic_vector(1 downto 0) := (others => '0'); --to determine what types of stack instructions is needed
    signal s_memWrite :  std_logic := '0'; --store
    signal s_memRead :  std_logic := '0'; --load
    signal s_isRti :  std_logic := '0';
    signal s_isProtect :  std_logic := '0';
    signal s_isFree :  std_logic := '0';
    -- Input data signals
    signal s_aluResult :std_logic_vector(31 downto 0) := (others => '0');
    signal s_vRs2 :  std_logic_vector(31 downto 0) := (others => '0');
    signal s_aRd :  std_logic_vector(2 downto 0) := (others => '0');
    signal s_aRs2 :  std_logic_vector(2 downto 0) := (others => '0');
    signal s_pc :  std_logic_vector(31 downto 0) := (others => '0');
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
        -- reset outputs
    ELSIF rising_edge(i_clk) THEN
      IF i_en = '1' THEN
        s_WB <= i_WB;
        s_stackControl <= i_stackControl;
        s_memWrite <= i_memWrite;
        s_memRead <= i_memRead;
        s_isRti <= i_isRti;
        s_isProtect <= i_isProtect;
        s_isFree <= i_isFree;
        -- Input data signals
        s_aluResult <= i_aluResult;
        s_vRs2 <= i_vRs2;
        s_aRd <= i_aRd;
        s_aRs2 <= i_aRs2;
        s_pc <= i_pc;
      
      END IF;
    END IF;
  END PROCESS;
  --set the outputs u need
END ARCHITECTURE imp;