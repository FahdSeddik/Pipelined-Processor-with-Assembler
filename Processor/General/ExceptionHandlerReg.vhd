LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ExceptionHandlerReg IS
  PORT (
    -- inputs
    i_we : IN STD_LOGIC;
    i_EPCMem : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- EPC for memory violation
    i_EPCExec : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- EPC for exception
    i_memory_violation : IN STD_LOGIC := '0';
    i_overflow : IN STD_LOGIC := '0';
    -- outputs
    o_EPCMem : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_EPCExec : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_exception_memory_violation : OUT STD_LOGIC;
    o_exception_overflow : OUT STD_LOGIC
  );
END ExceptionHandlerReg;

ARCHITECTURE Behavioral OF ExceptionHandlerReg IS
BEGIN
  o_EPCExec <= i_EPCExec WHEN i_we = '1' ELSE
    o_EPCExec;

  o_EPCMem <= i_EPCMem WHEN i_we = '1' ELSE
    o_EPCMem;

  o_exception_memory_violation <= i_memory_violation WHEN i_we = '1' ELSE
    o_exception_memory_violation;

  o_exception_overflow <= i_overflow WHEN i_we = '1' ELSE
    o_exception_overflow;
END Behavioral;