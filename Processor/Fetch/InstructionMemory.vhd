LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY InstructionMemory IS
  PORT (
    -- inputs
    i_address : IN STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    -- outputs
    o_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
  );
END ENTITY InstructionMemory;

ARCHITECTURE behavioral OF InstructionMemory IS
  TYPE t_memory IS ARRAY (0 TO 2 ** 12 - 1) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL r_mem : t_memory;
BEGIN
  o_instruction <= r_mem(TO_INTEGER(UNSIGNED(i_address)));
END ARCHITECTURE behavioral;