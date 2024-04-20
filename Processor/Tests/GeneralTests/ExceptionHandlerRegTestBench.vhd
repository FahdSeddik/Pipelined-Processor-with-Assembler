LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ExceptionHandlerRegTestBench IS
END ExceptionHandlerRegTestBench;

ARCHITECTURE behavior OF ExceptionHandlerRegTestBench IS
  --Inputs
  SIGNAL i_we : STD_LOGIC := '0';
  SIGNAL i_EPC : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL i_memory_violation : STD_LOGIC := '0';
  SIGNAL i_overflow : STD_LOGIC := '0';

  --Outputs
  SIGNAL o_EPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL o_exception_memory_violation : STD_LOGIC;
  SIGNAL o_exception_overflow : STD_LOGIC;

BEGIN

  -- Ipstantiate the Unit Under Test (UUT)
  uut : ENTITY work.ExceptionHandlerReg PORT MAP(
    i_we => i_we,
    i_EPC => i_EPC,
    i_memory_violation => i_memory_violation,
    i_overflow => i_overflow,
    o_EPC => o_EPC,
    o_exception_memory_violation => o_exception_memory_violation,
    o_exception_overflow => o_exception_overflow
    );

  -- Stimulus process
  stim_proc : PROCESS
    CONSTANT c_clk_period : TIME := 10 ps;
  BEGIN
    -- hold reset state for 100 ns.
    WAIT FOR 10 ps;

    -- Case 1: i_memory_violation = '1', i_overflow = '1'
    i_we <= '1';
    i_EPC <= "00000000000000000000000000000001";
    i_memory_violation <= '1';
    i_overflow <= '1';
    WAIT FOR c_clk_period;
    ASSERT (o_exception_memory_violation = '1' AND o_exception_overflow = '1') REPORT "Case 1 failed" SEVERITY ERROR;

    -- Case 2: i_memory_violation = '0', i_overflow = '1'
    i_we <= '1';
    i_EPC <= "00000000000000000000000000000010";
    i_memory_violation <= '0';
    i_overflow <= '1';
    WAIT FOR c_clk_period;
    ASSERT (o_exception_memory_violation = '0' AND o_exception_overflow = '1') REPORT "Case 2 failed" SEVERITY ERROR;

    -- Case 3: i_memory_violation = '1', i_overflow = '0'
    i_we <= '1';
    i_EPC <= "00000000000000000000000000000011";
    i_memory_violation <= '1';
    i_overflow <= '0';
    WAIT FOR c_clk_period;
    ASSERT (o_exception_memory_violation = '1' AND o_exception_overflow = '0') REPORT "Case 3 failed" SEVERITY ERROR;

    -- Case 4: i_memory_violation = '0', i_overflow = '0'
    i_we <= '1';
    i_EPC <= "00000000000000000000000000000100";
    i_memory_violation <= '0';
    i_overflow <= '0';
    WAIT FOR c_clk_period;
    ASSERT (o_exception_memory_violation = '0' AND o_exception_overflow = '0') REPORT "Case 4 failed" SEVERITY ERROR;

    -- Case 5: i_we = '0', i_memory_violation = '1', i_overflow = '1'
    i_we <= '0';
    i_EPC <= "00000000000000000000000000000001";
    i_memory_violation <= '1';
    i_overflow <= '1';
    WAIT FOR c_clk_period;
    ASSERT (o_exception_memory_violation = '0' AND o_exception_overflow = '0') REPORT "Case 5 failed" SEVERITY ERROR;

    -- Case 6: i_we = '0', i_memory_violation = '0', i_overflow = '1'
    i_we <= '0';
    i_EPC <= "00000000000000000000000000000010";
    i_memory_violation <= '0';
    i_overflow <= '1';
    WAIT FOR c_clk_period;
    ASSERT (o_exception_memory_violation = '0' AND o_exception_overflow = '0') REPORT "Case 6 failed" SEVERITY ERROR;

    -- Case 7: i_we = '0', i_memory_violation = '1', i_overflow = '0'
    i_we <= '0';
    i_EPC <= "00000000000000000000000000000011";
    i_memory_violation <= '1';
    i_overflow <= '0';
    WAIT FOR c_clk_period;
    ASSERT (o_exception_memory_violation = '0' AND o_exception_overflow = '0') REPORT "Case 7 failed" SEVERITY ERROR;

    -- Case 8: i_we = '0', i_memory_violation = '0', i_overflow = '0'
    i_we <= '0';
    i_EPC <= "00000000000000000000000000000100";
    i_memory_violation <= '0';
    i_overflow <= '0';
    WAIT FOR c_clk_period;
    ASSERT (o_exception_memory_violation = '0' AND o_exception_overflow = '0') REPORT "Case 8 failed" SEVERITY ERROR;
    WAIT;
  END PROCESS;

END;