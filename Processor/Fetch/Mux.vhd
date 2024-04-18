LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Mux IS
  PORT (
    i_input : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- 16-bit instruction or immediate value
    i_selector : IN STD_LOGIC := '0'; -- exception
    o_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0') -- 16-bit output
  );
END Mux;

ARCHITECTURE behavioral OF Mux IS
BEGIN
  o_output <= i_input WHEN i_selector = '0' ELSE
    (OTHERS => '0');
END behavioral;