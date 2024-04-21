LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IF_ID IS
  PORT (
    -- inputs
    i_clk : IN STD_LOGIC := '0';
    i_reset : IN STD_LOGIC := '0'; -- reset signal
    i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_en : IN STD_LOGIC := '0';
    i_instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    i_immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    -- outputs
    o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    o_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    o_immediate : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
  );
END ENTITY IF_ID;

ARCHITECTURE Behavioral OF IF_ID IS
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- if reset is high
      o_pc <= (OTHERS => '0'); -- reset outputs
      o_instruction <= (OTHERS => '0');
      o_immediate <= (OTHERS => '0');
    ELSIF rising_edge(i_clk) THEN
      IF i_en = '1' THEN
        o_pc <= i_pc;
        o_instruction <= i_instruction;
        o_immediate <= i_immediate;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE Behavioral;