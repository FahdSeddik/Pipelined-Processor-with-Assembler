LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY Fetch_TestBench IS
END ENTITY;

ARCHITECTURE behavioural OF Fetch_TestBench IS
  -- inputs
  SIGNAL w_i_branch : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_i_we : STD_LOGIC := '0';
  SIGNAL w_i_exception : STD_LOGIC := '0';
  SIGNAL w_i_freeze : STD_LOGIC := '0';
  SIGNAL w_i_clk : STD_LOGIC := '0';
  SIGNAL w_i_reset : STD_LOGIC := '0';

  -- outputs
  SIGNAL w_o_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL w_o_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL w_o_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);

  -- internal signals
  SIGNAL w_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL w_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL w_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);

  -- clock period definitions
  CONSTANT c_clk_period : TIME := 10 ps;

BEGIN
  -- instantiate the fetch stage
  fetch : ENTITY work.Fetch PORT MAP (
    i_branch => w_i_branch,
    i_we => w_i_we,
    i_exception => w_i_exception,
    i_freeze => w_i_freeze,
    i_clk => w_i_clk,
    o_pc => w_pc,
    o_instruction => w_instruction,
    o_immediate => w_immediate
    );

  -- fetch decode register
  IF_ID : ENTITY work.IF_ID PORT MAP (
    i_clk => w_i_clk,
    i_reset => w_i_reset,
    i_pc => w_pc,
    i_en => '1',
    i_instruction => w_instruction,
    i_immediate => w_immediate,
    o_pc => w_o_pc,
    o_instruction => w_o_instruction,
    o_immediate => w_o_immediate
    );

  -- Clock process definitions
  clk_process : PROCESS
  BEGIN
    w_i_clk <= '1';
    WAIT FOR c_clk_period/2;
    w_i_clk <= '0';
    WAIT FOR c_clk_period/2;
  END PROCESS;

  -- Stimulus process
  stim_proc : PROCESS
    TYPE t_memory IS ARRAY (0 TO 2 ** 12 - 1) OF STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- functions
    FUNCTION init_memory RETURN t_memory IS
      VARIABLE result : t_memory;
    BEGIN
      FOR i IN result'RANGE LOOP
        IF i = 7 THEN
          result(i) := STD_LOGIC_VECTOR(to_unsigned(8199, result(i)'LENGTH)); -- 8199 is the decimal equivalent of 1000000000000111
        ELSE
          result(i) := STD_LOGIC_VECTOR(to_unsigned(i, result(i)'LENGTH));
        END IF;
      END LOOP;
      RETURN result;
    END FUNCTION init_memory;

    -- constants
    CONSTANT c_mem_expected : t_memory := init_memory;
    CONSTANT c_c_exception_handler : STD_LOGIC_VECTOR(31 DOWNTO 0) := (11 => '1', OTHERS => '0'); -- TODO change to real exception handler
    CONSTANT c_NOP : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    CONSTANT c_instr_w_immediate_address : STD_LOGIC_VECTOR(11 DOWNTO 0) := x"007";

  BEGIN
    WAIT FOR 1 ps;
    -- -- Test 1: Basic fetch functionality, normal conditions
    ASSERT w_o_pc = x"00000000" REPORT "Test 1 Failed: PC not updating correctly" SEVERITY ERROR;
    ASSERT w_o_instruction = c_mem_expected(to_integer(unsigned(w_o_pc))) REPORT "Test 1 Failed: Instruction not fetched correctly" SEVERITY ERROR;
    WAIT FOR c_clk_period;
    ASSERT w_o_pc = x"00000001" REPORT "Test 1 Failed: PC not incrementing correctly" SEVERITY ERROR;
    ASSERT w_o_instruction = c_mem_expected(to_integer(unsigned(w_o_pc))) REPORT "Test 1 Failed: Instruction not fetched correctly" SEVERITY ERROR;
    WAIT FOR c_clk_period;
    ASSERT w_o_pc = x"00000002" REPORT "Test 1 Failed: PC not incrementing correctly" SEVERITY ERROR;
    ASSERT w_o_instruction = c_mem_expected(to_integer(unsigned(w_o_pc))) REPORT "Test 1 Failed: Instruction not fetched correctly" SEVERITY ERROR;
    WAIT FOR c_clk_period;
    ASSERT w_o_pc = x"00000003" REPORT "Test 1 Failed: PC not incrementing correctly" SEVERITY ERROR;
    ASSERT w_o_instruction = c_mem_expected(to_integer(unsigned(w_o_pc))) REPORT "Test 1 Failed: Instruction not fetched correctly" SEVERITY ERROR;
    WAIT FOR c_clk_period;
    ASSERT w_o_pc = x"00000004" REPORT "Test 1 Failed: PC not incrementing correctly" SEVERITY ERROR;
    ASSERT w_o_instruction = c_mem_expected(to_integer(unsigned(w_o_pc))) REPORT "Test 1 Failed: Instruction not fetched correctly" SEVERITY ERROR;

    -- -- Test 2: Exception handling, reset outputs
    w_i_exception <= '1';
    WAIT FOR c_clk_period;
    ASSERT w_o_pc = c_c_exception_handler REPORT "Test 2 Failed: PC should go to exception handling adress" SEVERITY ERROR;
    w_i_exception <= '0'; -- Reset exception signal for subsequent tests

    -- -- Test 3: Freeze functionality, outputs should hold
    w_i_freeze <= '1';
    w_i_branch <= x"00000002"; -- Change branch but should not take effect
    w_i_we <= '1';
    WAIT FOR c_clk_period;
    ASSERT w_o_pc = c_c_exception_handler REPORT "Test 3 Failed: PC should not change on freeze" SEVERITY ERROR;
    w_i_freeze <= '0';

    -- -- Test 4: Disable write, pc should increment normally
    w_i_we <= '0';
    w_i_branch <= x"00000003";
    WAIT FOR c_clk_period * 2;
    ASSERT w_o_pc = STD_LOGIC_VECTOR(unsigned(c_c_exception_handler) + to_unsigned(1, w_o_pc'length)) REPORT "Test 4 Failed: PC should increment normally when write disabled" SEVERITY ERROR;

    -- -- Test 5: Sequential updates, simulate rapid changes
    -- w_i_we <= '1';
    -- WAIT FOR c_clk_period;
    -- FOR i IN 0 TO 4 LOOP
    --   w_i_branch <= STD_LOGIC_VECTOR(unsigned(w_i_branch) + to_unsigned(i * 2, 32));
    --   WAIT FOR c_clk_period;
    --   ASSERT w_o_pc = STD_LOGIC_VECTOR(unsigned(w_i_branch) + to_unsigned(i * 2, 32)) REPORT "Test 5 Failed: Sequential branch updates not handled correctly" SEVERITY ERROR;
    -- END LOOP;

    -- -- Test 6: Immediate after regular instruction, should handle separately
    -- w_i_we <= '1';
    -- w_i_branch <= x"00000" & c_instr_w_immediate_address; -- Instruction requiring immediate
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_instruction = c_NOP REPORT "Test 6 Failed: Immediate value case not handled correctly" SEVERITY ERROR;
    -- w_i_we <= '0';
    -- WAIT FOR c_clk_period; -- should have the immediate and the instruction
    -- ASSERT w_o_instruction = c_mem_expected(to_integer(unsigned(w_i_branch))) REPORT "Test 6 Failed: Immediate value not handled correctly" SEVERITY ERROR;
    -- ASSERT w_o_immediate = c_mem_expected(to_integer(unsigned(w_i_branch) + to_unsigned(1, w_o_immediate'length))) REPORT "Test 6 Failed: Immediate value not handled correctly" SEVERITY ERROR;

    -- -- Test 7: Check reset functionality
    -- w_i_reset <= '1';
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = c_NOP & c_NOP AND w_o_instruction = c_NOP AND w_o_immediate = c_NOP REPORT "Test 7 Failed: Reset not functioning correctly" SEVERITY ERROR;
    -- w_i_reset <= '0';

    -- -- Test 8: Simulate edge cases for the PC increment
    -- w_i_branch <= x"FFFFFFFF"; -- Edge of address space
    -- w_i_we <= '1';
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = x"FFFFFFFF" REPORT "Test 8 Failed: Edge case for PC increment not handled" SEVERITY ERROR;

    -- -- Test 9: Check handling of all zeros
    -- w_i_branch <= (OTHERS => '0');
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = w_i_branch REPORT "Test 9 Failed: Zero input not handled correctly" SEVERITY ERROR;

    -- -- Test 10: Check for rapid toggling of enable
    -- w_i_we <= '1';
    -- w_i_branch <= x"00000004";
    -- WAIT FOR c_clk_period;
    -- w_i_we <= '0';
    -- WAIT FOR c_clk_period;
    -- w_i_we <= '1';
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = x"00000004" REPORT "Test 10 Failed: Rapid toggling of enable not handled" SEVERITY ERROR;

    -- -- Test 11: Instruction fetch under simultaneous branch and exception
    -- w_i_branch <= x"00000006";
    -- w_i_we <= '1';
    -- w_i_exception <= '1';
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = c_c_exception_handler REPORT "Test 11 Failed: Exception should override branch" SEVERITY ERROR;
    -- w_i_exception <= '0'; -- Reset exception signal for subsequent tests
    -- w_i_we <= '0';

    -- -- Test 12: Check if the PC wraps around the maximum value
    -- w_i_branch <= x"FFFFFFFE";
    -- w_i_we <= '1';
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = x"FFFFFFFE" REPORT "Test 12 Failed: PC at max minus one should update correctly" SEVERITY ERROR;
    -- WAIT FOR c_clk_period * 2;
    -- ASSERT w_o_pc = x"00000000" REPORT "Test 12 Failed: PC should wrap around to zero after maximum" SEVERITY ERROR;

    -- -- Test 13: Freeze functionality during exception handling
    -- w_i_exception <= '1';
    -- w_i_freeze <= '1';
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = c_c_exception_handler REPORT "Test 13 Failed: PC should hold exception address during freeze" SEVERITY ERROR;
    -- w_i_freeze <= '0';
    -- w_i_exception <= '0';

    -- -- Test 14: Confirm NOP instruction behaves as expected without changing state
    -- w_i_branch <= x"00000008";
    -- w_i_we <= '1';
    -- WAIT FOR c_clk_period;
    -- w_i_we <= '0'; -- Disable write enable
    -- w_i_branch <= x"00000009"; -- Attempt to change branch
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = x"00000008" REPORT "Test 14 Failed: PC should not update when write is disabled" SEVERITY ERROR;

    -- -- Test 15: Validate immediate value handling when w_i_branch changes rapidly
    -- w_i_we <= '1';
    -- w_i_branch <= x"00000" & c_instr_w_immediate_address;
    -- WAIT FOR c_clk_period;
    -- w_i_branch <= STD_LOGIC_VECTOR(unsigned(c_instr_w_immediate_address) + to_unsigned(1, w_i_branch'length));
    -- WAIT FOR c_clk_period * 2;
    -- ASSERT w_o_instruction = c_mem_expected(to_integer(unsigned(w_i_branch))) AND w_o_immediate = c_mem_expected(to_integer(unsigned(w_i_branch)) + 1) REPORT "Test 15 Failed: Immediate value should update correctly on rapid branch changes" SEVERITY ERROR;

    -- -- Test 16: Check instruction fetch after multiple NOP cycles
    -- FOR j IN 1 TO 3 LOOP
    --   w_i_we <= '0';
    --   WAIT FOR c_clk_period;
    -- END LOOP;
    -- w_i_we <= '1';
    -- w_i_branch <= x"0000000C";
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_instruction = c_mem_expected(to_integer(unsigned(w_i_branch))) REPORT "Test 16 Failed: Instruction should fetch correctly after NOP cycles" SEVERITY ERROR;

    -- -- Test 17: Testing reset functionality during active write-enable
    -- w_i_reset <= '1';
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = c_NOP & c_NOP AND w_o_instruction = c_NOP AND w_o_immediate = c_NOP REPORT "Test 17 Failed: Reset should clear all outputs even if write is enabled" SEVERITY ERROR;
    -- w_i_reset <= '0';

    -- -- Test 18: Validate branch updates only occur on positive clock edge
    -- w_i_clk <= '0'; -- Ensure clock is low
    -- w_i_branch <= x"0000000D";
    -- WAIT FOR c_clk_period/2; -- Half period should not trigger updates
    -- ASSERT w_o_pc /= x"0000000D" REPORT "Test 18 Failed: PC should not update on half clock period" SEVERITY ERROR;
    -- w_i_clk <= '1'; -- Clock goes high
    -- WAIT FOR c_clk_period/2;
    -- ASSERT w_o_pc = x"0000000D" REPORT "Test 18 Failed: PC should update on rising edge of clock" SEVERITY ERROR;

    -- -- Test 19: Confirm correct behavior when freeze and exception are toggled simultaneously
    -- w_i_freeze <= '1';
    -- w_i_exception <= '1';
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_pc = c_c_exception_handler REPORT "Test 19 Failed: Exception should override freeze and update PC" SEVERITY ERROR;
    -- w_i_exception <= '0';
    -- w_i_freeze <= '0';

    -- -- Test 20: Test instruction and immediate fetches under rapid toggle of w_i_we
    -- w_i_we <= '1';
    -- w_i_branch <= x"F000000E";
    -- WAIT FOR c_clk_period;
    -- w_i_we <= '0';
    -- w_i_branch <= x"0000000F";
    -- WAIT FOR c_clk_period;
    -- ASSERT w_o_instruction = c_mem_expected(to_integer(unsigned(w_i_branch)) - 1) AND w_o_immediate = c_mem_expected(to_integer(unsigned(w_i_branch))) REPORT "Test 20 Failed: Toggling w_i_we should not affect fetched values" SEVERITY ERROR;

    WAIT;
  END PROCESS;

END ARCHITECTURE;