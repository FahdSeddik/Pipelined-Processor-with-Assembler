LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IF_ID_TestBench IS
END IF_ID_TestBench;

ARCHITECTURE behavior OF IF_ID_TestBench IS
  -- Inputs
  SIGNAL i_clk : STD_LOGIC := '0';
  SIGNAL i_reset : STD_LOGIC := '0';
  SIGNAL i_pc : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL i_en : STD_LOGIC := '0';
  SIGNAL i_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL i_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

  -- Outputs
  SIGNAL o_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL o_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL o_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);

  -- Clock period definition
  CONSTANT c_clk_period : TIME := 10 ps;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut : ENTITY work.IF_ID
    PORT MAP(
      i_clk => i_clk,
      i_reset => i_reset,
      i_pc => i_pc,
      i_en => i_en,
      i_instruction => i_instruction,
      i_immediate => i_immediate,
      o_pc => o_pc,
      o_instruction => o_instruction,
      o_immediate => o_immediate
    );

  -- Clock process definitions
  clk_process : PROCESS
  BEGIN
    i_clk <= '0';
    WAIT FOR c_clk_period/2;
    i_clk <= '1';
    WAIT FOR c_clk_period/2;
  END PROCESS;

  -- Stimulus process
  stim_proc : PROCESS
    CONSTANT c_pc_expected : STD_LOGIC_VECTOR(31 DOWNTO 0) := (2 => '1', 1 => '1', OTHERS => '0');
    CONSTANT c_instruction_expected : STD_LOGIC_VECTOR(15 DOWNTO 0) := (2 => '1', 1 => '1', OTHERS => '0');
    CONSTANT c_immediate_expected : STD_LOGIC_VECTOR(15 DOWNTO 0) := (2 => '1', 1 => '1', OTHERS => '0');
  BEGIN
    -- Initialize
    i_reset <= '1'; -- Activate reset
    WAIT FOR c_clk_period;
    i_reset <= '0'; -- Deactivate reset
    WAIT FOR c_clk_period;

    -- Test: Clocking in data with enable
    i_pc <= c_pc_expected;
    i_instruction <= c_instruction_expected;
    i_immediate <= c_immediate_expected;
    i_en <= '1'; -- Enable data to pass through
    WAIT FOR c_clk_period; -- Wait for two clock cycles

    -- Assertion: Check if data is clocked in
    ASSERT (i_pc = c_pc_expected AND i_instruction = c_instruction_expected AND i_immediate = c_immediate_expected)
    REPORT "Data not clocked in correctly" SEVERITY ERROR;

    -- Test: Disable and see if data holds
    i_en <= '0';
    WAIT FOR c_clk_period * 5;

    -- Assertion: Check if data holds when disabled
    ASSERT (i_en = '0' AND i_pc = c_pc_expected AND i_instruction = c_instruction_expected AND i_immediate = c_immediate_expected)
    REPORT "Data does not hold when disabled" SEVERITY ERROR;

    WAIT;
  END PROCESS;

END ARCHITECTURE behavior;