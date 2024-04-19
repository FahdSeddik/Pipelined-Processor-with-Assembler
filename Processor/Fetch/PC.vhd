LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PC IS
  PORT (
    --inputs
    i_branch : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_we : IN STD_LOGIC := '0';
    i_exception : IN STD_LOGIC := '0'; -- mem violation or overflow
    i_freeze : IN STD_LOGIC := '0';
    i_clk : IN STD_LOGIC := '0';
    --outputs
    o_adress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
  );
END ENTITY PC;

ARCHITECTURE behavioral OF PC IS
  SIGNAL r_pc : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  CONSTANT c_exception_handler : STD_LOGIC_VECTOR(31 DOWNTO 0) := (11 => '1', OTHERS => '0'); -- TODO change to real exception handler
BEGIN

  PROCESS (ALL)
  BEGIN
    IF i_exception = '1' THEN
      r_pc <= c_exception_handler;
    ELSIF rising_edge(i_clk) THEN
      IF i_freeze = '1' THEN
        r_pc <= r_pc; -- freeze -> do nothing
      ELSE
        IF i_we = '1' THEN
          r_pc <= i_branch;
        ELSE
          r_pc <= STD_LOGIC_VECTOR(unsigned(r_pc) + to_unsigned(1, 32));
        END IF;
      END IF;
    ELSE
      r_pc <= r_pc;
    END IF;
  END PROCESS;

  o_adress <= r_pc;

END ARCHITECTURE behavioral;