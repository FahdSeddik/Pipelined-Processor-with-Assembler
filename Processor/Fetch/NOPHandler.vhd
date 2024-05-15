LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY NOPHandler IS
  PORT (
    -- inputs
    i_instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    i_isNOP : IN STD_LOGIC := '0';
    -- outpus
    o_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
  );
END NOPHandler;

ARCHITECTURE behavioral OF NOPHandler IS
BEGIN
  PROCESS (ALL)
  BEGIN
    IF i_isNOP = '1' THEN
      o_instruction <= (OTHERS => '0');
    ELSE
      o_instruction <= i_instruction;
    END IF;
  END PROCESS;
END behavioral; -- behavioral