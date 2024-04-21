LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY DECODE_3_REGISTERS IS
PORT(
i_opCode : IN std_logic_vector(3 downto 0);
o_controlSignals : OUT std_logic_vector(15 downto 0)
);
END ENTITY;

ARCHITECTURE struct OF DECODE_3_REGISTERS IS
SIGNAL w_aluOP : std_logic_vector(3 downto 0) := (others => '0');
SIGNAL w_WB : std_logic_vector(1 downto 0) := (others => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
SIGNAL w_stackControl : std_logic_vector(1 downto 0) := (others => '0'); --to determine what types of stack instructions is needed
SIGNAL w_memWrite : std_logic := '0'; --store
SIGNAL w_memRead : std_logic := '0'; --load
SIGNAL w_inputEnable : std_logic := '0'; --on in
SIGNAL w_outputEnable : std_logic := '0'; --on out
SIGNAL w_isProtect : std_logic := '0';
SIGNAL w_isFree : std_logic := '0';
SIGNAL w_branchControl : std_logic_vector(1 downto 0) := (others => '0');

-- 1.ADD	0000 -> 1000
-- 2.SUB	0001 -> 1001
-- 3.AND	0010 -> 0101
-- 4.OR 	0011 -> 0110
-- 5.XOR	0100 -> 0111

BEGIN
o_controlSignals(15 downto 12) <= w_aluOP;
o_controlSignals(11 downto 10) <= w_WB;
o_controlSignals(9 downto 8) <= w_stackControl;
o_controlSignals(7) <= w_memWrite;
o_controlSignals(6) <= w_memRead;
o_controlSignals(5) <= w_inputEnable;
o_controlSignals(4) <= w_outputEnable;
o_controlSignals(3) <= w_isProtect;
o_controlSignals(2) <= w_isFree;
o_controlSignals(1 downto 0) <= w_branchControl;


w_aluOP <=  "1000" WHEN i_opCode = "0000" ELSE
            "1001" WHEN i_opCode = "0001" ELSE
            "0101" WHEN i_opCode = "0010" ELSE
            "0110" WHEN i_opCode = "0011" ELSE
            "0111" WHEN i_opCode = "0100" ELSE
            "0000";
w_WB <= "10" WHEN   i_opCode = "0000" OR i_opCode = "0001" OR i_opCode = "0100" OR
                    i_opCode = "0010" OR i_opCode = "0011" ELSE
        "00";
w_stackControl <= "00";
w_memWrite <= '0';
w_memRead <= '0';
w_inputEnable <= '0';
w_outputEnable <= '0';
w_isProtect <= '0';
w_isFree <= '0';
w_branchControl <= "00";

END ARCHITECTURE;