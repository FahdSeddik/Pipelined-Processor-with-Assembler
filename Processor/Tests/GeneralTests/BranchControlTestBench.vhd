LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY BranchControlTestBench IS
END BranchControlTestBench;

ARCHITECTURE behavioral OF BranchControlTestBench IS
  --Inputs
  SIGNAL w_i_branch_control : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_i_branch_adress : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_i_z_flag : STD_LOGIC := '0';

  --Outputs
  SIGNAL w_o_branch_control : STD_LOGIC;
  SIGNAL w_o_branch_adress : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : ENTITY work.BranchControl PORT MAP(
    i_branch_control => w_i_branch_control,
    i_branch_adress => w_i_branch_adress,
    i_z_flag => w_i_z_flag,
    o_branch_control => w_o_branch_control,
    o_branch_adress => w_o_branch_adress
    );

  -- Stimulus process
  stim_proc : PROCESS
    CONSTANT c_branch_adress0 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (3 => '1', OTHERS => '0');
    CONSTANT c_branch_adress1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (4 => '1', OTHERS => '0');
    CONSTANT c_branch_adress2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (5 => '1', OTHERS => '0');
  BEGIN
    -- hold reset state for 10 ps.
    WAIT FOR 10 ps;

    w_i_branch_control <= "00";
    w_i_branch_adress <= c_branch_adress0;
    w_i_z_flag <= '0';
    WAIT FOR 10 ps;
    ASSERT w_o_branch_control = '0' REPORT "Test failed: w_o_branch_control should be '0'" SEVERITY error;
    ASSERT w_o_branch_adress = c_branch_adress0 REPORT "Test failed: w_o_branch_adress should be (3 => '1', OTHERS => '0')" SEVERITY error;

    w_i_branch_control <= "01";
    w_i_branch_adress <= c_branch_adress1;
    w_i_z_flag <= '0';
    WAIT FOR 10 ps;
    ASSERT w_o_branch_control = '1' REPORT "Test failed: w_o_branch_control should be '0'" SEVERITY error;
    ASSERT w_o_branch_adress = c_branch_adress1 REPORT "Test failed: w_o_branch_adress should be (4 => '1', OTHERS => '0')" SEVERITY error;

    w_i_branch_control <= "10";
    w_i_branch_adress <= c_branch_adress2;
    w_i_z_flag <= '1';
    WAIT FOR 10 ps;
    ASSERT w_o_branch_control = '1' REPORT "Test failed: w_o_branch_control should be '1'" SEVERITY error;
    ASSERT w_o_branch_adress = c_branch_adress2 REPORT "Test failed: w_o_branch_adress should be (5 => '1', OTHERS => '0')" SEVERITY error;

    w_i_branch_control <= "10";
    w_i_branch_adress <= c_branch_adress0;
    w_i_z_flag <= '0';
    WAIT FOR 10 ps;
    ASSERT w_o_branch_control = '0' REPORT "Test failed: w_o_branch_control should be '1'" SEVERITY error;
    ASSERT w_o_branch_adress = c_branch_adress0 REPORT "Test failed: w_o_branch_adress should be (3 => '1', OTHERS => '0')" SEVERITY error;

    w_i_branch_control <= "11";
    w_i_branch_adress <= c_branch_adress1;
    w_i_z_flag <= '1';
    WAIT FOR 10 ps;
    ASSERT w_o_branch_control = '0' REPORT "Test failed: w_o_branch_control should be '1'" SEVERITY error;
    ASSERT w_o_branch_adress = c_branch_adress1 REPORT "Test failed: w_o_branch_adress should be (3 => '1', OTHERS => '0')" SEVERITY error;

    WAIT;
  END PROCESS;

END;