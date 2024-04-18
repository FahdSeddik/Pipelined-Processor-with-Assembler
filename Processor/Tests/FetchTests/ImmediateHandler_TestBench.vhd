LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ImmediateHandler_TestBench IS
END ImmediateHandler_TestBench;

ARCHITECTURE behavioral OF ImmediateHandler_TestBench IS
  -- Inputs
  SIGNAL i_input : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL i_clk : STD_LOGIC := '0';

  -- Outputs
  SIGNAL o_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL o_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);

  -- Clock period definitions
  CONSTANT c_clk_period : TIME := 10 ps;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut : ENTITY work.ImmediateHandler
    PORT MAP(
      i_clk => i_clk,
      i_input => i_input,
      o_instruction => o_instruction,
      o_immediate => o_immediate
    );

  -- Clock process definitions
  i_clk_process : PROCESS
  BEGIN
    i_clk <= '1';
    WAIT FOR c_clk_period/2;
    i_clk <= '0';
    WAIT FOR c_clk_period/2;
  END PROCESS;

  -- Stimulus process
  stim_proc : PROCESS
    CONSTANT c_intruction_w_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0) := "1000111100001111";
    CONSTANT c_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000011111111";
    CONSTANT c_instruction_wo_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000111100001111";
    CONSTANT c_NOP : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  BEGIN
    -- Test 1: Input without immediate
    i_input <= c_instruction_wo_immediate; -- Instruction without immediate
    WAIT FOR c_clk_period;
    ASSERT (o_instruction = c_instruction_wo_immediate) REPORT "Test 1: Input without immediate failed. Expected: " & to_string(c_instruction_wo_immediate) & " got: " & to_string(o_instruction) SEVERITY error;

    -- Test 2: Input with immediate needs two cycles
    i_input <= c_intruction_w_immediate; -- Instruction with immediate
    WAIT FOR c_clk_period;
    ASSERT (o_instruction = c_NOP) REPORT "Test 2: Expected instruction to be zero initially (NOP). Got: " & to_string(o_instruction) SEVERITY error;
    i_input <= c_immediate; -- Immediate value
    WAIT FOR c_clk_period;
    ASSERT (o_instruction = c_intruction_w_immediate) REPORT "Test 2: Expected instruction to be " & to_string(c_intruction_w_immediate) & ". Got: " & to_string(o_instruction) SEVERITY error;
    ASSERT (o_immediate = c_immediate) REPORT "Test 2: Expected immediate to be " & to_string(c_immediate) & ". Got: " & to_string(o_immediate) SEVERITY error;

    WAIT;
  END PROCESS;

END ARCHITECTURE behavioral;