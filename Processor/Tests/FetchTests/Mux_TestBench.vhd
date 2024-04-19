LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Mux_TestBench IS
END Mux_TestBench;

ARCHITECTURE behavioral OF Mux_TestBench IS
  -- Inputs
  SIGNAL i_input : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL i_selector : STD_LOGIC := '0';

  -- Outputs
  SIGNAL o_output : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
  -- Ipstantiate the Unit Under Test (UUT)
  uut : ENTITY work.Mux
    PORT MAP(
      i_input => i_input,
      i_selector => i_selector,
      o_output => o_output
    );

  -- Stimulus process
  stim_proc : PROCESS
    CONSTANT c_exception_expected : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    CONSTANT c_no_exception_expected : STD_LOGIC_VECTOR(15 DOWNTO 0) := "1010101010101010";
  BEGIN
    -- Test with no exception
    i_input <= c_no_exception_expected;
    i_selector <= '0'; -- No exception
    WAIT FOR 10 ps;
    ASSERT (o_output = c_no_exception_expected) REPORT "No exception test failed" SEVERITY error;

    -- Test with exception
    i_selector <= '1'; -- Exception occurs
    WAIT FOR 10 ps;
    ASSERT (o_output = c_exception_expected) REPORT "Exception test failed" SEVERITY error;

    -- Test with no exception again
    i_input <= c_no_exception_expected;
    i_selector <= '0'; -- No exception
    WAIT FOR 10 ps;
    ASSERT (o_output = c_no_exception_expected) REPORT "No exception test (2) failed" SEVERITY error;

    WAIT;
  END PROCESS;

END ARCHITECTURE behavioral;