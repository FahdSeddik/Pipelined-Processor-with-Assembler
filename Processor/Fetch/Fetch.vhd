LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Fetch IS
  PORT (
    --inputs
    -- branch
    i_branch_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_branch_we : IN STD_LOGIC := '0';
    i_forward_pc : IN STD_LOGIC := '0';
    -- predict
    i_predict_we : IN STD_LOGIC := '0';
    i_predict_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    -- general
    i_exception : IN STD_LOGIC := '0'; -- mem violation or overflow
    i_freeze : IN STD_LOGIC := '0';
    i_clk : IN STD_LOGIC := '0';
    i_reset : IN STD_LOGIC := '0';
    i_interrupt : IN STD_LOGIC := '0';
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
  SIGNAL w_pc_stall_out : STD_LOGIC := '0';
  SIGNAL w_immediate_instruction_out : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_pc_out : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN
  -- components
  pc : ENTITY work.pc
    PORT MAP(
      i_instruction => w_instruction_memory_out,
      i_interrupt => i_interrupt,
      i_branch_address => i_branch_address,
      i_branch_we => i_branch_we,
      i_predict_we => i_predict_we,
      i_predict_address => i_predict_address,
      i_exception => i_exception,
      i_freeze => i_freeze,
      i_clk => i_clk,
      i_reset => i_reset,
      o_address => w_pc_out,
      o_stall => w_pc_stall_out
    );

  instruction_memory : ENTITY work.instructionMemory
    PORT MAP(
      i_address => o_pc(11 DOWNTO 0),
      o_instruction => w_instruction_memory_out
    );

  mux : ENTITY work.mux
    PORT MAP(
      i_input => w_instruction_memory_out,
      i_selector => i_exception,
      o_output => w_mux_out
    );

  mux2 : ENTITY work.mux2
    PORT MAP(
      i_pc => w_pc_out,
      i_branch_adress => i_branch_address,
      i_forward_pc => i_forward_pc,
      o_output => o_pc
    );

  immediate_handling : ENTITY work.immediateHandler
    PORT MAP(
      i_clk => i_clk,
      i_reset => i_reset,
      i_input => w_mux_out,
      o_instruction => w_immediate_instruction_out,
      o_immediate => o_immediate,
      i_enable => NOT(w_pc_stall_out)
    );

  NOPHandler : ENTITY work.NOPHandler
    PORT MAP(
      i_instruction => w_immediate_instruction_out,
      i_isNOP => w_pc_stall_out,
      o_instruction => o_instruction
    );

END ARCHITECTURE behavioral;