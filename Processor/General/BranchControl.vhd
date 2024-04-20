LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY BranchControl IS
  PORT (
    -- inputs
    i_branch_control : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; -- a branch in
    -- 00 = no branch, 01 = branch always (jmp), 10 = branch if equal (JZ), 11 = XXX
    i_branch_adress : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- adress to jump
    i_z_flag : IN STD_LOGIC := '0';
    -- outputs
    o_branch_control : OUT STD_LOGIC := '0'; -- branch out
    o_branch_adress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
  );
END ENTITY BranchControl;

ARCHITECTURE behavioral OF BranchControl IS
BEGIN
  o_branch_control <= (NOT(i_branch_control(1)) AND i_branch_control(0)) OR (i_branch_control(1) AND NOT(i_branch_control(0)) AND i_z_flag) OR '0';
  o_branch_adress <= i_branch_adress;
END ARCHITECTURE behavioral;