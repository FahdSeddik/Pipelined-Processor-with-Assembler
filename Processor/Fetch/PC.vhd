LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PC IS
  PORT (
    -- inputs
    i_clk : IN STD_LOGIC := '0';
    i_exception : IN STD_LOGIC := '0'; -- mem violation or overflow
    i_freeze : IN STD_LOGIC := '0';
    i_interrupt : IN STD_LOGIC := '0';
    i_reset : IN STD_LOGIC := '0';
    i_instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    i_branch_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_branch_we : IN STD_LOGIC := '0';
    i_predict_we : IN STD_LOGIC := '0';
    i_predict_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    -- outputs
    o_address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    o_stall : OUT STD_LOGIC := '0'
  );
END ENTITY PC;

ARCHITECTURE behavioral OF PC IS
  TYPE state_type IS (NORMAL, GET_RESET_ADDRESS, GET_INTERRUPT_ADDRESS);
  -- constants
  CONSTANT c_exception_handler : STD_LOGIC_VECTOR(31 DOWNTO 0) := (11 => '1', OTHERS => '0'); -- TODO change to real exception handler
BEGIN

  main_loop : PROCESS (i_clk, i_reset, i_interrupt, i_freeze, i_branch_we, i_predict_we)
    VARIABLE r_pc : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    VARIABLE r_state : state_type := NORMAL;
    VARIABLE r_reset_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    VARIABLE r_reset_counter : INTEGER := 0; -- take the address on 2 cycles
    VARIABLE r_interrupt_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    VARIABLE r_interrupt_counter : INTEGER := 0; -- take the address on 2 cycles
  BEGIN
    IF i_reset = '1' AND (r_state /= GET_RESET_ADDRESS) THEN
      r_state := GET_RESET_ADDRESS;
      r_pc := (OTHERS => '0'); -- start reading at 0x00000000
      o_address <= r_pc;
      o_stall <= '1';
    ELSIF i_interrupt = '1' AND (r_state /= GET_INTERRUPT_ADDRESS) THEN
      r_state := GET_INTERRUPT_ADDRESS;
      r_pc := (1 => '1', OTHERS => '0'); -- start reading at 0x00000002
      o_address <= r_pc;
      o_stall <= '1';
    ELSIF i_freeze = '1' THEN
      o_address <= r_pc; -- freeze -> do nothing
    ELSIF i_branch_we = '1' AND rising_edge(i_clk) THEN
      r_pc := i_branch_address;
      o_address <= r_pc;
    ELSIF rising_edge(i_predict_we) THEN
      r_pc := i_predict_address;
      o_address <= r_pc;
    ELSIF rising_edge(i_clk) THEN
      IF r_state = NORMAL THEN
        r_pc := STD_LOGIC_VECTOR(unsigned(r_pc) + 1);
        o_address <= r_pc;
      ELSIF r_state = GET_RESET_ADDRESS THEN
        r_reset_counter := r_reset_counter + 1;
        IF r_reset_counter = 1 THEN
          r_reset_address(31 DOWNTO 16) := i_instruction;
          -- r_reset_address := r_reset_address SLL 16;
          r_pc := (0 => '1', OTHERS => '0'); -- start reading at 0x00000000
          o_address <= r_pc;
        ELSIF r_reset_counter = 2 THEN
          r_reset_address(15 DOWNTO 0) := i_instruction;
          r_pc := r_reset_address; -- address is ready
          o_address <= r_pc;
          r_state := NORMAL; -- go back to normal
          r_reset_counter := 0;
          r_reset_address := (OTHERS => '0');
          o_stall <= '0';
        END IF;
      ELSIF r_state = GET_INTERRUPT_ADDRESS THEN
        r_interrupt_counter := r_interrupt_counter + 1;
        IF r_interrupt_counter = 1 THEN
          r_interrupt_address(31 DOWNTO 16) := i_instruction;
          r_pc := (1 => '1', 0 => '1', OTHERS => '0'); -- start reading at 0x00000003
          o_address <= r_pc;
        ELSIF r_interrupt_counter = 2 THEN
          r_interrupt_address(15 DOWNTO 0) := i_instruction;
          r_pc := r_interrupt_address; -- address is ready
          o_address <= r_pc;
          r_state := NORMAL; -- go back to normal
          r_interrupt_counter := 0;
          r_interrupt_address := (OTHERS => '0');
          o_stall <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE behavioral;