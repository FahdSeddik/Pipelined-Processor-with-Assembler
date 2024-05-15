LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Mux2 IS
  PORT (
    i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- 16-bit instruction or immediate value
    i_branch_adress : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- 16-bit instruction or immediate value
    i_forward_pc : IN STD_LOGIC := '0'; -- exception
    o_output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0') -- 16-bit output
  );
END ENTITY;

ARCHITECTURE behavioral OF Mux2 IS
BEGIN
  o_output <= i_branch_adress WHEN i_forward_pc = '1' ELSE
    i_pc;
END behavioral;