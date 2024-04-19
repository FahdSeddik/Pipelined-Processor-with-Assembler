LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY InstructionMemory_TestBench IS
END InstructionMemory_TestBench;

ARCHITECTURE behavioral OF InstructionMemory_TestBench IS
  -- Inputs
  SIGNAL i_address : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');

  -- Outputs
  SIGNAL o_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);

  -- Clock period definitions
  CONSTANT c_clk_period : TIME := 10 ps;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut : ENTITY work.InstructionMemory
    PORT MAP(
      i_address => i_address,
      o_instruction => o_instruction
    );

  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- Test with different addresses
    FOR i IN 0 TO 6 LOOP
      i_address <= STD_LOGIC_VECTOR(to_unsigned(i, 12));
      WAIT FOR c_clk_period; -- Wait for two clock cycles to see the output

      -- Assertion
      ASSERT o_instruction = STD_LOGIC_VECTOR(to_unsigned(i, 12))
      REPORT "Memory content at address " & INTEGER'image(i) & " is not as expected"
        SEVERITY ERROR;
    END LOOP;

    WAIT;
  END PROCESS;

END ARCHITECTURE behavioral;