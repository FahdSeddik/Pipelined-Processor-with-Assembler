LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ExceptionHandlerReg IS
  PORT (
    -- inputs
    i_we : IN STD_LOGIC;
    i_EPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_memory_violation : IN STD_LOGIC := '0';
    i_overflow : IN STD_LOGIC := '0';
    -- outputs
    o_EPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_exception_memory_violation : OUT STD_LOGIC;
    o_exception_overflow : OUT STD_LOGIC
  );
END ExceptionHandlerReg;

ARCHITECTURE Behavioral OF ExceptionHandlerReg IS
BEGIN
  o_EPC <= i_EPC WHEN i_we = '1' ELSE
    o_EPC;

  o_exception_memory_violation <= i_memory_violation WHEN i_we = '1' ELSE
    o_exception_memory_violation;

  o_exception_overflow <= i_overflow WHEN i_we = '1' ELSE
    o_exception_overflow;
END Behavioral;