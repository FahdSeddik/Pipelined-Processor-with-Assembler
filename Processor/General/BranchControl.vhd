LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY BranchControl IS
  PORT (
    -- inputs
    i_branch_control : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; -- a branch in
    -- 00 = no branch, 01 = branch always (jmp), 10 = branch if equal (JZ), 11 = call
    i_alu_res : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); 
    i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_bit_predictor : IN STD_LOGIC;
    i_z_flag : IN STD_LOGIC := '0';
    i_return : IN STD_LOGIC := '0';
    i_branch_adress : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    -- outputs
    o_branch_control : OUT STD_LOGIC := '0'; -- branch out
    o_branch_adress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
  );
END ENTITY BranchControl;

ARCHITECTURE behavioral OF BranchControl IS
  signal s_branch_result : STD_LOGIC := '0';
BEGIN
  s_branch_result <= '1' WHEN i_branch_control = "10" AND i_z_flag = '1' ELSE
                     '1' WHEN i_branch_control /= "00" AND i_branch_control /= "10" ELSE
                     '0';
  o_branch_control <= (s_branch_result XOR i_bit_predictor) when i_branch_control /= "00" ELSE
                      i_return;
  o_branch_adress <= i_branch_adress WHEN i_return = '1' ELSE -- prio mem
                      i_alu_res WHEN s_branch_result /= o_branch_control AND not i_bit_predictor ELSE
                      i_pc + 1;

END ARCHITECTURE behavioral;