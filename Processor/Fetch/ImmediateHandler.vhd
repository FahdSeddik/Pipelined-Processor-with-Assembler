LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ImmediateHandler IS
  PORT (
    i_clk : IN STD_LOGIC := '0';
    i_input : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
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
    IF falling_edge(i_clk) THEN
      CASE r_state IS
        WHEN instruction_wait =>
          IF i_input(15) = '1' THEN -- has immediate
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
    END IF;
  END PROCESS;

  o_instruction <= r_instruction;
  o_immediate <= r_immediate;

END ARCHITECTURE behavioral;