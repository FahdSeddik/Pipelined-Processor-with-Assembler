LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ExceptionHandler IS
  PORT (
    -- inputs
    i_mem_violation : IN STD_LOGIC;
    i_overflow : IN STD_LOGIC;
    -- outputs
    o_exception : OUT STD_LOGIC;
    o_flush : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) -- 1 bit for memory (1), 1 bit for fetch and execute (1)
    -- 00 - no flush
    -- 01 - flush fetch and execute
    -- 11 - flush fetch and execute and memory
    -- 10 - XXX
  );
END ExceptionHandler;

ARCHITECTURE Behavioral OF ExceptionHandler IS
BEGIN
  o_exception <= i_mem_violation OR i_overflow;
  o_flush <= "11" WHEN i_mem_violation = '1' ELSE
    "01" WHEN i_overflow = '1' ELSE
    "00";
END Behavioral;