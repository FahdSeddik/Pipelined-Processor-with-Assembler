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
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
        o_WB <= (others => '0');
        o_stackControl <= (others => '0');
        o_memWrite <= '0';
        o_memRead <= '0';
        o_isRti <= '0';
        o_isProtect <= '0';
        o_isFree <= '0';
        o_aluResult <= (others => '0');
        o_vRs2 <= (others => '0');
        o_aRd <= (others => '0');
        o_aRs2 <= (others => '0');
        o_pc <= (others => '0');
    ELSIF rising_edge(i_clk) THEN
      IF i_en = '1' THEN
        o_WB <= i_WB;
        o_stackControl <= i_stackControl;
        o_memWrite <= i_memWrite;
        o_memRead <= i_memRead;
        o_isRti <= i_isRti;
        o_isProtect <= i_isProtect;
        o_isFree <= i_isFree;
        o_aluResult <= i_aluResult;
        o_vRs2 <= i_vRs2;
        o_aRd <= i_aRd;
        o_aRs2 <= i_aRs2;
        o_pc <= i_pc;
      
      END IF;
    END IF;
  END PROCESS;
  --set the outputs u need
END ARCHITECTURE imp;