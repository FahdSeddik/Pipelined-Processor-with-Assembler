LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY DECODE IS
PORT(
i_clk : IN std_logic := '0';
i_reset : IN std_logic := '0';
-- Input from fetch
i_instruction : IN std_logic_vector(15 downto 0) := (others => '0'); --for decoding
i_immediate : IN std_logic_vector(15 downto 0) := (others => '0'); --for sign extend
i_pc : IN std_logic_vector(31 downto 0) := (others => '0'); --no-logic signal
-- Input from writeback (for register file)
i_writeEnable : IN std_logic_vector(1 downto 0) := (others => '0'); -- i_writeEnable[1]->normal i_writeEnable[0]->on if swap
i_data0 : IN std_logic_vector(31 downto 0) := (others => '0'); --normally if wb[1]
i_data1 : IN std_logic_vector(31 downto 0) := (others => '0'); --to address 0 and 0 to address 1 if swap
i_wbAddress0 : IN std_logic_vector(2 downto 0) := (others => '0');
i_wbAddress1 : IN std_logic_vector(2 downto 0) := (others => '0');
-- Input from HDU
i_hduClearControl : IN std_logic := '0';
-- Input from execution
i_exeClearControl : IN std_logic := '0';
-- Output control signals
o_WB : OUT std_logic_vector(1 downto 0) := (others => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
o_stackControl : OUT std_logic_vector(1 downto 0) := (others => '0'); --to determine what types of stack instructions is needed
o_memWrite : OUT std_logic := '0'; --store
o_memRead : OUT std_logic := '0'; --load
o_inputEnable : OUT std_logic := '0'; --on in
o_outputEnable : OUT std_logic := '0'; --on out
o_isImm : OUT std_logic := '0'; -- bit in instruction
o_isProtect : OUT std_logic := '0';
o_isFree : OUT std_logic := '0';
o_branchControl : OUT std_logic_vector(1 downto 0) := (others => '0');
-- Output signals from decode
o_aluOP : OUT std_logic_vector(3 downto 0) := (others => '0');
o_vRs1 : OUT std_logic_vector(31 downto 0) := (others => '0');
o_vRs2 : OUT std_logic_vector(31 downto 0) := (others => '0');
o_vImmediate : OUT std_logic_vector(31 downto 0) := (others => '0');
o_aRs1 : OUT std_logic_vector(2 downto 0) := (others => '0');
o_aRs2 : OUT std_logic_vector(2 downto 0) := (others => '0');
o_aRd : OUT std_logic_vector(2 downto 0) := (others => '0');
-- Output no-logic wires
o_pc : OUT std_logic_vector(31 downto 0) := (others => '0')
);
-- Instruction understanding
--31. .... ... ... ... .   .... ..98 7654 3210
-- XX XXXX XXX XXX XXX X | XXXX XXXX XXXX XXXX
-- 2 bits num inputs [15:14]
-- 4 bits instruction type/op code [13:10]
-- 3 bits destination [9:7]
-- 3 bits source 1 [6:4]
-- 3 bits source 2 [3:1]
-- 1 bit has immediate [0]
END ENTITY;

ARCHITECTURE struct of DECODE IS

SIGNAL opcode : std_logic_vector(3 downto 0) := (others => '0');
SIGNAL num_inputs : std_logic_vector(1 downto 0) := (others => '0');
SIGNAL w_rAddress0, w_rAddress1 : std_logic_vector(2 downto 0) := (others => '0');
SIGNAL w_wbAddress0, w_wbAddress1 : std_logic_vector(2 downto 0) := (others => '0');
SIGNAL w_cS0, w_cS1, w_cS2, w_cS3 : std_logic_vector(15 downto 0) := (others => '0');
SIGNAL w_controlSignals : std_logic_vector(15 downto 0) := (others => '0');
COMPONENT REGISTER_FILE IS
PORT(
i_clk : IN std_logic;
i_reset : IN std_logic;
i_we0 : IN std_logic;
i_we1 : IN std_logic;
i_rAddress0 : IN std_logic_vector(2 downto 0);
i_rAddress1 : IN std_logic_vector(2 downto 0);
i_wAddress0 : IN std_logic_vector(2 downto 0);
i_wAddress1 : IN std_logic_vector(2 downto 0);
i_wData0 : IN std_logic_vector(31 downto 0);
i_wData1 : IN std_logic_vector(31 downto 0);
-- Output
o_rData0 : IN std_logic_vector(31 downto 0);
o_rData1 : IN std_logic_vector(31 downto 0)
);
END COMPONENT;

COMPONENT DECODE_0_REGISTERS IS
PORT(
i_opCode : IN std_logic_vector(3 downto 0);
o_controlSignals : OUT std_logic_vector(15 downto 0)
);
END COMPONENT;

COMPONENT DECODE_1_REGISTERS IS
PORT(
i_opCode : IN std_logic_vector(3 downto 0);
o_controlSignals : OUT std_logic_vector(15 downto 0)
);
END COMPONENT;

COMPONENT DECODE_2_REGISTERS IS
PORT(
i_opCode : IN std_logic_vector(3 downto 0);
o_controlSignals : OUT std_logic_vector(15 downto 0)
);
END COMPONENT;

COMPONENT DECODE_3_REGISTERS IS
PORT(
i_opCode : IN std_logic_vector(3 downto 0);
o_controlSignals : OUT std_logic_vector(15 downto 0)
);
END COMPONENT;



BEGIN
-- if swap we swap writeback addresses
w_wbAddress0 <= i_wbAddress1 WHEN i_writeEnable(0) = '1' ELSE
                i_wbAddress0;
w_wbAddress1 <= i_wbAddress0 WHEN i_writeEnable(0) = '1' ELSE
                i_wbAddress1;
RF : REGISTER_FILE PORT MAP(i_clk, i_reset, i_writeEnable(0), i_writeEnable(1), w_rAddress0, w_rAddress1,
                            w_wbAddress0, w_wbAddress1, i_data0, i_data1, o_vRs1, o_vRs2); --data1 in 0 and data0 in 1 due writeEnable

-- Connect static outputs
o_aRd <= i_instruction(9 downto 7);
o_aRs1 <= w_rAddress0;
o_aRs2 <= w_rAddress1;
w_rAddress0 <= i_instruction(6 downto 4);
w_rAddress1 <= i_instruction(3 downto 1);
o_isImm <= i_instruction(0);
o_pc <= i_pc;
-- Assign opcode and number of inputs from instruction
num_inputs <= i_instruction(15 downto 14);
opcode <= i_instruction(13 downto 10);
o_vImmediate(31 downto 16) <= (others => i_immediate(15));
o_vImmediate(15 downto 0) <= i_immediate;


D0 : DECODE_0_REGISTERS PORT MAP(i_instruction(13 downto 10), w_cS0);
D1 : DECODE_1_REGISTERS PORT MAP(i_instruction(13 downto 10), w_cS1);
D2 : DECODE_2_REGISTERS PORT MAP(i_instruction(13 downto 10), w_cS2);
D3 : DECODE_3_REGISTERS PORT MAP(i_instruction(13 downto 10), w_cS3);

-- Wiring mux based on instruction register count
w_controlSignals <= (others => '0') WHEN i_hduClearControl = '1' OR i_exeClearControl = '1' ELSE
                    w_cS0 WHEN i_instruction(15 downto 14) = "00" ELSE
                    w_cS1 WHEN i_instruction(15 downto 14) = "01" ELSE
                    w_cS2 WHEN i_instruction(15 downto 14) = "10" ELSE
                    w_cS3;

o_aluOP <= w_controlSignals(15 downto 12);
o_WB <= w_controlSignals(11 downto 10);
o_stackControl <= w_controlSignals(9 downto 8);
o_memWrite <= w_controlSignals(7);
o_memRead <= w_controlSignals(6);
o_inputEnable <= w_controlSignals(5);
o_outputEnable <= w_controlSignals(4);
o_isProtect <= w_controlSignals(3);
o_isFree <= w_controlSignals(2);
o_branchControl <= w_controlSignals(1 downto 0);

END ARCHITECTURE;


