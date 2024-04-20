LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ExceptionHandlerTestBench IS
END ExceptionHandlerTestBench;

ARCHITECTURE behavioral OF ExceptionHandlerTestBench IS
  --Inputs
  SIGNAL i_mem_violation : STD_LOGIC := '0';
  SIGNAL i_overflow : STD_LOGIC := '0';

  --Outputs
  SIGNAL o_exception : STD_LOGIC;
  SIGNAL o_flush : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : ENTITY work.ExceptionHandler PORT MAP(
    i_mem_violation => i_mem_violation,
    i_overflow => i_overflow,
    o_exception => o_exception,
    o_flush => o_flush
    );

  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- hold reset state for 10 ps.
    WAIT FOR 10 ps;

    i_mem_violation <= '0';
    i_overflow <= '0'; -- test case 1: no violation, no overflow
    WAIT FOR 10 ps;

    ASSERT (o_exception = '0' AND o_flush = "00") REPORT "Test case 1 failed" SEVERITY error;

    i_mem_violation <= '0';
    i_overflow <= '1'; -- test case 2: no violation, overflow
    WAIT FOR 10 ps;

    ASSERT (o_exception = '1' AND o_flush = "01") REPORT "Test case 2 failed" SEVERITY error;

    i_mem_violation <= '1';
    i_overflow <= '0'; -- test case 3: violation, no overflow
    WAIT FOR 10 ps;

    ASSERT (o_exception = '1' AND o_flush = "11") REPORT "Test case 3 failed" SEVERITY error;

    i_mem_violation <= '1';
    i_overflow <= '1'; -- test case 4: violation, overflow
    WAIT FOR 10 ps;

    ASSERT (o_exception = '1' AND o_flush = "11") REPORT "Test case 4 failed" SEVERITY error;

    WAIT;
  END PROCESS;

END;