LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PC_TestBench IS
END PC_TestBench;

ARCHITECTURE behavioral OF PC_TestBench IS
  --Inputs
  SIGNAL i_branch : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL i_we : STD_LOGIC := '0';
  SIGNAL i_exception : STD_LOGIC := '0';
  SIGNAL i_freeze : STD_LOGIC := '0';
  SIGNAL i_clk : STD_LOGIC := '0';
  SIGNAL i_reset : STD_LOGIC := '0';
  SIGNAL i_interrupt : STD_LOGIC := '0';

  --Outputs
  SIGNAL o_adress : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- Clock period definitions
  CONSTANT c_clk_period : TIME := 10 ps;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut : ENTITY work.PC PORT MAP(
    i_branch => i_branch,
    i_we => i_we,
    i_exception => i_exception,
    i_freeze => i_freeze,
    i_clk => i_clk,
    o_adress => o_adress,
    i_reset => i_reset,
    i_interrupt => i_interrupt
    );

  -- Clock process definitions
  i_clk_process : PROCESS
  BEGIN
    i_clk <= '0';
    WAIT FOR c_clk_period/2;
    i_clk <= '1';
    WAIT FOR c_clk_period/2;
  END PROCESS;

  -- Stimulus process
  stim_proc : PROCESS
    CONSTANT c_exception_handler : STD_LOGIC_VECTOR(31 DOWNTO 0) := (11 => '1', OTHERS => '0'); -- TODO change to real exception handler
    CONSTANT base_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    CONSTANT branch_offset : STD_LOGIC_VECTOR(31 DOWNTO 0) := (31 => '0', OTHERS => '1');
    CONSTANT c_reset_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    CONSTANT c_interrupt_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (4 => '1', OTHERS => '0');
  BEGIN
    -- hold reset state for 100 ps.
    WAIT FOR 10 ps;

    -- Reset test
    i_reset <= '1';
    WAIT FOR c_clk_period * 2;
    ASSERT (o_adress = c_reset_address) REPORT "Unexpected address after reset" SEVERITY ERROR;
    i_reset <= '0';

    -- Interrupt test
    i_interrupt <= '1';
    WAIT FOR c_clk_period * 2;
    ASSERT (o_adress = c_interrupt_address) REPORT "Unexpected address after interrupt" SEVERITY ERROR;
    i_interrupt <= '0';

    i_we <= '1';
    i_branch <= branch_offset;
    WAIT FOR c_clk_period * 2;

    -- Assertion
    ASSERT (o_adress = i_branch) REPORT "Unexpected address after write enable" SEVERITY ERROR;

    i_we <= '0';
    WAIT FOR c_clk_period * 2;

    -- Assertion
    ASSERT (o_adress = STD_LOGIC_VECTOR(unsigned(i_branch) + to_unsigned(2, 32))) REPORT "Unexpected address AFTER write disable" SEVERITY ERROR;

    i_exception <= '1';
    WAIT FOR c_clk_period * 2;

    -- Assertion
    ASSERT (o_adress = c_exception_handler) REPORT "Unexpected address after exception" SEVERITY ERROR;

    i_exception <= '0';
    i_freeze <= '1';
    WAIT FOR c_clk_period * 2;

    -- Assertion
    ASSERT (o_adress = c_exception_handler) REPORT "Unexpected address after freeze" SEVERITY ERROR;

    i_freeze <= '0';
    WAIT FOR c_clk_period * 2;

    -- Assertion
    ASSERT (o_adress = STD_LOGIC_VECTOR(unsigned(c_exception_handler) + to_unsigned(2, 32))) REPORT "Unexpected address after unfreeze" SEVERITY ERROR;

    WAIT;
  END PROCESS;

END;