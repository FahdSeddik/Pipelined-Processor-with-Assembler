LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ImmediateHandler IS
  PORT (
    -- inputs
    i_clk : IN STD_LOGIC := '0';
    i_reset : IN STD_LOGIC; -- added reset signal
    i_input : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    i_enable : IN STD_LOGIC := '1'; -- to enable normal logic
    -- outputs
    o_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    o_immediate : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
  );
END ENTITY ImmediateHandler;

ARCHITECTURE behavioral OF ImmediateHandler IS
  TYPE t_state IS (instruction_wait, imediate_wait);
  -- Registers
  SIGNAL r_state : t_state := instruction_wait;
  SIGNAL r_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL r_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  -- temp register to hold the instruction in case of needs immediate
  SIGNAL r_temp : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_reset = '1' THEN -- added reset condition
      r_state <= instruction_wait;
      r_instruction <= (OTHERS => '0');
      r_immediate <= (OTHERS => '0');
      r_temp <= (OTHERS => '0');
    ELSIF falling_edge(i_clk) AND i_enable = '1' THEN
      CASE r_state IS
        WHEN instruction_wait =>
          IF i_input(0) = '1' THEN -- has immediate
            r_temp <= i_input;
            r_instruction <= (OTHERS => '0'); -- nop
            r_immediate <= (OTHERS => '0');
            r_state <= imediate_wait;
          ELSE
            r_instruction <= i_input;
            r_immediate <= (OTHERS => '0'); -- Don't care
            r_state <= instruction_wait;
          END IF;
        WHEN imediate_wait =>
          r_immediate <= i_input;
          r_instruction <= r_temp;
          r_state <= instruction_wait;
        WHEN OTHERS =>
          r_state <= instruction_wait;
      END CASE;
    ELSE
      r_instruction <= i_input;
      r_immediate <= (OTHERS => '0');
    END IF;
  END PROCESS;

  o_instruction <= r_instruction;
  o_immediate <= r_immediate;

END ARCHITECTURE behavioral;