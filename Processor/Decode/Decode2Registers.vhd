LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY DECODE_2_REGISTERS IS
PORT(
i_opCode : IN std_logic_vector(3 downto 0);
o_controlSignals : OUT std_logic_vector(14 downto 0)
);
END ENTITY;

ARCHITECTURE struct OF DECODE_2_REGISTERS IS
SIGNAL w_aluOP : std_logic_vector(3 downto 0) := (others => '0');
SIGNAL w_WB : std_logic_vector(1 downto 0) := (others => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
SIGNAL w_stackControl : std_logic_vector(1 downto 0) := (others => '0'); --to determine what types of stack instructions is needed
SIGNAL w_memWrite : std_logic := '0'; --store
SIGNAL w_memRead : std_logic := '0'; --load
SIGNAL w_inputEnable : std_logic := '0'; --on in
SIGNAL w_outputEnable : std_logic := '0'; --on out
SIGNAL w_isProtect : std_logic := '0';
SIGNAL w_isFree : std_logic := '0';
SIGNAL w_isBranch : std_logic := '0';

-- 1.MOV	0000 -> MOV dest,a -> aluOP = a(0000) ? //
-- 2.SWAP	0001 -> 0000 //
-- 3.ADDI	0010 -> 1000 //
-- 4.SUBI	0011 -> 1001 //
-- 5.LDD	0100 -> 0000 //
-- 6.CMP	0101 -> 1001 //
-- 7.STD	0110 -> 0000 //
-- 8.NOT 	0111 -> 0100 //
-- 9.NEG 	1000 -> 1100 //
-- 10.INC 	1001 -> 1010 //
-- 11.DEC 	1010 -> 1011 //
BEGIN
o_controlSignals(14 downto 11) <= w_aluOP;
o_controlSignals(10 downto 9) <= w_WB;
o_controlSignals(8 downto 7) <= w_stackControl;
o_controlSignals(6) <= w_memWrite;
o_controlSignals(5) <= w_memRead;
o_controlSignals(4) <= w_inputEnable;
o_controlSignals(3) <= w_outputEnable;
o_controlSignals(2) <= w_isProtect;
o_controlSignals(1) <= w_isFree;
o_controlSignals(0) <= w_isBranch;

w_aluOP <=  "1000" WHEN i_opCode = "0010" ELSE
            "1001" WHEN i_opCode = "0011" OR i_opCode = "0101" ELSE
            "0100" WHEN i_opCode = "0111" ELSE
            "1100" WHEN i_opCode = "1000" ELSE
            "1010" WHEN i_opCode = "1001" ELSE
            "1011" WHEN i_opCode = "1010" ELSE
            "0000";
w_WB <= "10" WHEN   i_opCode = "0111" OR i_opCode = "1000" OR
                    i_opCode = "1001" OR i_opCode = "1010" OR
                    i_opCode = "0100" OR i_opCode = "0011" OR
                    i_opCode = "0010" OR i_opCode = "0000" ELSE
        "11" WHEN   i_opCode = "0001" ELSE
        "00";
w_stackControl <= "00";
w_memWrite <= '1' WHEN i_opCode = "0110" ELSE '0';
w_memRead <= '1' WHEN i_opCode = "0100" ELSE '0';
w_inputEnable <= '0';
w_outputEnable <= '0';
w_isProtect <= '0';
w_isFree <= '0';
w_isBranch <= '0';

END ARCHITECTURE;