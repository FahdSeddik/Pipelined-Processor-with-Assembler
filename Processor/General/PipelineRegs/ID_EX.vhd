LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ID_EX IS
  PORT (
    -- Input control signals
    i_WB : OUT std_logic_vector(1 downto 0) := (others => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
    i_stackControl : OUT std_logic_vector(1 downto 0) := (others => '0'); --to determine what types of stack instructions is needed
    i_memWrite : OUT std_logic := '0'; --store
    i_memRead : OUT std_logic := '0'; --load
    i_isRti : OUT std_logic := '0';
    i_inputEnable : OUT std_logic := '0'; --on in
    i_outputEnable : OUT std_logic := '0'; --on out
    i_isImm : OUT std_logic := '0'; -- bit in instruction
    i_isProtect : OUT std_logic := '0';
    i_isFree : OUT std_logic := '0';
    i_isBranch : OUT std_logic := '0';
    -- Input signals from decode
    i_aluOP : OUT std_logic_vector(3 downto 0) := (others => '0');
    i_vRs1 : OUT std_logic_vector(31 downto 0) := (others => '0');
    i_vRs2 : OUT std_logic_vector(31 downto 0) := (others => '0');
    i_vImmediate : OUT std_logic_vector(31 downto 0) := (others => '0');
    i_aRs1 : OUT std_logic_vector(2 downto 0) := (others => '0');
    i_aRs2 : OUT std_logic_vector(2 downto 0) := (others => '0');
    i_aRd : OUT std_logic_vector(2 downto 0) := (others => '0');
    -- Input no-logic wires
    i_pc : OUT std_logic_vector(31 downto 0) := (others => '0') -- ### ADD SEMI-COLON
    -- Output ### ADD SEMI-COLON ABOVE
  );
END ENTITY ID_EX;

ARCHITECTURE Behavioral OF ID_EX IS
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
        -- reset outputs
    ELSIF rising_edge(i_clk) THEN
      IF i_en = '1' THEN
        -- set outputs
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE Behavioral;