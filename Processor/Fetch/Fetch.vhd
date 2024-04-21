LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Fetch IS
  PORT (
    --inputs
    i_branch : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_we : IN STD_LOGIC := '0';
    i_exception : IN STD_LOGIC := '0'; -- mem violation or overflow
    i_freeze : IN STD_LOGIC := '0';
    i_clk : IN STD_LOGIC := '0';
    -- outputs
    o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    o_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    o_immediate : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
  );
END Fetch;

ARCHITECTURE behavioral OF Fetch IS
  -- internal signals
  SIGNAL w_instruction_memory_out : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_mux_out : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN
  -- components
  pc : ENTITY work.pc
    PORT MAP(
      i_branch => i_branch,
      i_we => i_we,
      i_exception => i_exception,
      i_freeze => i_freeze,
      i_clk => i_clk,
      o_adress => o_pc
    );

  instruction_memory : ENTITY work.instructionMemory
    PORT MAP(
      i_clk => i_clk,
      i_address => o_pc(11 DOWNTO 0),
      o_instruction => w_instruction_memory_out
    );

  mux : ENTITY work.mux
    PORT MAP(
      i_input => w_instruction_memory_out,
      i_selector => i_exception,
      o_output => w_mux_out
    );

  immediate_handling : ENTITY work.immediateHandler
    PORT MAP(
      i_clk => i_clk,
      i_input => w_mux_out,
      o_instruction => o_instruction,
      o_immediate => o_immediate
    );

END ARCHITECTURE behavioral;