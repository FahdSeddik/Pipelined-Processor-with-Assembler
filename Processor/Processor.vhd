LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Processor IS
PORT(
    i_clk : IN std_logic;
    i_reset : IN std_logic;
    i_port : IN std_logic_vector(31 downto 0);
    o_port : OUT std_logic_vector(31 downto 0)
);
END ENTITY;


ARCHITECTURE struct OF Processor IS
-- Fetch, Reg, Decode, Reg, Ex, Reg, Mem, Reg, Wb
-- Exception handling, Branch control


-- ###################################
COMPONENT Fetch IS
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
END COMPONENT;

COMPONENT IF_ID IS
  PORT (
    -- inputs
    i_clk : IN STD_LOGIC := '0';
    i_reset : IN STD_LOGIC := '0'; -- reset signal
    i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    i_en : IN STD_LOGIC := '0';
    i_instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    i_immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    -- outputs
    o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    o_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    o_immediate : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
  );
END COMPONENT;

SIGNAL w_FD_PC_1, w_FD_PC_2 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_FD_instruction_1, w_FD_instruction_2 : std_logic_vector(15 downto 0) := (others => '0');
SIGNAL w_FD_immediate_1, w_FD_immediate_2 : std_logic_vector(15 downto 0) := (others => '0');
-- ###################################

-- ###################################
COMPONENT DECODE IS
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
END COMPONENT;

COMPONENT ID_EX IS
  PORT (
    i_clk,i_reset,i_en : in std_logic := '0';
    -- Input control signals
    i_WB : in std_logic_vector(1 downto 0) := (others => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
    i_stackControl : in std_logic_vector(1 downto 0) := (others => '0'); --to determine what types of stack instructions is needed
    i_memWrite : in std_logic := '0'; --store
    i_memRead : in std_logic := '0'; --load
    i_inputEnable : in std_logic := '0'; --on in
    i_outputEnable : in std_logic := '0'; --on out
    i_isImm : in std_logic := '0'; -- bit in instruction
    i_isProtect : in std_logic := '0';
    i_isFree : in std_logic := '0';
    i_branchControl : in std_logic_vector(1 downto 0) := (others => '0');
    -- Input signals from decode
    i_aluOP : in std_logic_vector(3 downto 0) := (others => '0');
    i_vRs1 : in std_logic_vector(31 downto 0) := (others => '0');
    i_vRs2 : in std_logic_vector(31 downto 0) := (others => '0');
    i_vImmediate : in std_logic_vector(31 downto 0) := (others => '0');
    i_aRs1 : in std_logic_vector(2 downto 0) := (others => '0');
    i_aRs2 : in std_logic_vector(2 downto 0) := (others => '0');
    i_aRd : in std_logic_vector(2 downto 0) := (others => '0');
    -- Input no-logic wires
    i_pc : out std_logic_vector(31 downto 0) := (others => '0'); 
    -- Output ### ADD SEMI-COLON ABOVE
    o_WB : out std_logic_vector(1 downto 0) := (others => '0');
    o_stackControl : out std_logic_vector(1 downto 0) := (others => '0');
    o_memWrite : out std_logic := '0';
    o_memRead : out std_logic := '0';
    o_inputEnable : out std_logic := '0';
    o_outputEnable : out std_logic := '0'; 
    o_isImm : out std_logic := '0'; 
    o_isProtect : out std_logic := '0';
    o_isFree : out std_logic := '0';
    o_branchControl : out std_logic_vector(1 downto 0) := (others => '0');
    o_aluOP : out std_logic_vector(3 downto 0) := (others => '0');
    o_vRs1 : out std_logic_vector(31 downto 0) := (others => '0');
    o_vRs2 : out std_logic_vector(31 downto 0) := (others => '0');
    o_vImmediate : out std_logic_vector(31 downto 0) := (others => '0');
    o_aRs1 : out std_logic_vector(2 downto 0) := (others => '0');
    o_aRs2 : out std_logic_vector(2 downto 0) := (others => '0');
    o_aRd : out std_logic_vector(2 downto 0) := (others => '0');
    -- Input no-logic wires
    o_pc : out std_logic_vector(31 downto 0) := (others => '0')
  );
END COMPONENT;
SIGNAL w_DE_WB_1, w_DE_WB_2 : std_logic_vector(1 downto 0) := (others => '0');
SIGNAL w_DE_stackControl_1,w_DE_stackControl_2 : std_logic_vector(1 downto 0) := (others => '0');
SIGNAL w_DE_memWrite_1, w_DE_memWrite_2 : std_logic := '0';
SIGNAL w_DE_memRead_1, w_DE_memRead_2 : std_logic := '0';
SIGNAL w_DE_inputEnable_1, w_DE_inputEnable_2 : std_logic := '0';
SIGNAL w_DE_outputEnable_1, w_DE_outputEnable_2 : std_logic := '0';
SIGNAL w_DE_isImm_1, w_DE_isImm_2 : std_logic := '0';
SIGNAL w_DE_isProtect_1, w_DE_isProtect_2 : std_logic := '0';
SIGNAL w_DE_isFree_1, w_DE_isFree_2 : std_logic := '0';
SIGNAL w_DE_branchControl_1,w_DE_branchControl_2 : std_logic_vector(1 downto 0) := (others => '0');
SIGNAL w_DE_aluOP_1, w_DE_aluOP_2 : std_logic_vector(3 downto 0) := (others => '0');
SIGNAL w_DE_vRs1_1, w_DE_vRs1_2 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_DE_vRs2_1, w_DE_vRs2_2 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_DE_vImmediate_1, w_DE_vImmediate_2 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_DE_aRs1_1, w_DE_aRs1_2 : std_logic_vector(2 downto 0) := (others => '0');
SIGNAL w_DE_aRs2_1, w_DE_aRs2_2 : std_logic_vector(2 downto 0) := (others => '0');
SIGNAL w_DE_aRd_1, w_DE_aRd_2 : std_logic_vector(2 downto 0) := (others => '0');
SIGNAL w_DE_PC_1, w_DE_PC_2 : std_logic_vector(31 downto 0) := (others => '0');
-- ###################################

-- ###################################
COMPONENT Execute is port(
    i_clk, i_reset: in std_logic;
    --control signals
    i_aluOp: in std_logic_vector(3 downto 0);
    i_inputEnable,i_outputEnable: in std_logic;
    i_isImm: in std_logic;
    --input port
    i_inputPort: in std_logic_vector(31 downto 0);
    --data signals from decode
    i_vRs1,i_vRs2,i_immediate: in std_logic_vector(31 downto 0);
    i_aRs1,i_aRs2: in std_logic_vector(2 downto 0);
    --data signals from memory
    i_vResult_ex,i_vRs2_ex: in std_logic_vector(31 downto 0);
    i_aRd_ex,i_aRs2_ex: in std_logic_vector(2 downto 0);
    i_WB_ex: in std_logic_vector(1 downto 0);
    --data signals from write back
    i_vResult_mem,i_vRs2_mem: in std_logic_vector(31 downto 0);
    i_aRd_mem,i_aRs2_mem: in std_logic_vector(2 downto 0);
    i_WB_mem: in std_logic_vector(1 downto 0);
    --output signal out of here
    o_overflow: out std_logic;
    o_result: out std_logic_vector(31 downto 0);
    o_output: out std_logic_vector(31 downto 0);
    o_vRs2: out std_logic_vector(31 downto 0);
    o_flags : out std_logic_vector(3 downto 0)
);
end COMPONENT Execute;

COMPONENT EX_MEM IS
  PORT (
    i_clk,i_reset,i_en : in std_logic := '0';
    -- Input control signals
    i_WB : in std_logic_vector(1 downto 0) := (others => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
    i_stackControl : in std_logic_vector(1 downto 0) := (others => '0'); --to determine what types of stack instructions is needed
    i_memWrite : in std_logic := '0'; --store
    i_memRead : in std_logic := '0'; --load
    i_isProtect : in std_logic := '0';
    i_isFree : in std_logic := '0';
    -- Input data signals
    i_aluResult : in std_logic_vector(31 downto 0) := (others => '0');
    i_vRs2 : in std_logic_vector(31 downto 0) := (others => '0');
    i_aRd : in std_logic_vector(2 downto 0) := (others => '0');
    i_aRs2 : in std_logic_vector(2 downto 0) := (others => '0');
    i_pc : in std_logic_vector(31 downto 0) := (others => '0');
    i_flag : in std_logic_vector(3 downto 0) := (others => '0');
    --output signals
    o_memRead : out std_logic;
    o_memWrite : out std_logic;
    o_WB : out std_logic_vector(1 downto 0); -- i_writeEnable[1]->normal i_writeEnable[0]->on if swap
    o_isProtect : out std_logic;
    o_isFree : out std_logic;
    o_stackControl : OUT std_logic_vector(1 downto 0);
    -- data
    o_aluResult : out std_logic_vector(31 downto 0); -- ALU result
    o_vRs2 : out std_logic_vector(31 downto 0);
    o_aRd : out std_logic_vector(2 downto 0);
    o_aRs2 : out std_logic_vector(2 downto 0);
    o_pc : out std_logic_vector(31 downto 0);
    o_flag : out std_logic_vector(3 downto 0)
  );
END COMPONENT EX_MEM;
SIGNAL w_EM_aluResult_1 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_EM_vRs2_1 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_EM_flags_1 : std_logic_vector(3 downto 0) := (others => '0');
SIGNAL w_EM_memRead : std_logic := '0';
SIGNAL w_EM_memWrite : std_logic := '0';
SIGNAL w_EM_WB : std_logic_vector(1 downto 0) := (others => '0');
SIGNAL w_EM_isProtect : std_logic := '0';
SIGNAL w_EM_isFree : std_logic := '0';
SIGNAL w_EM_stackControl : std_logic_vector(1 downto 0) := (others => '0');
SIGNAL w_EM_aluResult : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_EM_vRs2 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_EM_aRd : std_logic_vector(2 downto 0) := (others => '0');
SIGNAL w_EM_aRs2 : std_logic_vector(2 downto 0) := (others => '0');
SIGNAl w_EM_PC : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_EM_flag : std_logic_vector(3 downto 0) := (others => '0');
-- ###################################

-- ###################################
COMPONENT Memory IS
  PORT(
    i_clk : IN std_logic;
    i_reset : IN std_logic;
    -- input from excute stage
    -- control signals
    i_memRead : IN std_logic;
    i_memWrite : IN std_logic;
    i_writeBack : IN std_logic_vector(1 downto 0); -- i_writeEnable[1]->normal i_writeEnable[0]->on if swap
    i_protect : IN std_logic;
    i_free : IN std_logic;
    i_stackControl : IN std_logic_vector(1 downto 0);
    -- data
    i_result : IN std_logic_vector(31 downto 0); -- ALU result
    i_rdstAddr : IN std_logic_vector(2 downto 0);
    i_rs2Addr : IN std_logic_vector(2 downto 0);
    i_rs2Data : IN std_logic_vector(31 downto 0);
    i_pc : IN std_logic_vector(31 downto 0);
    i_flag : IN std_logic_vector(3 downto 0);
    -- output
    o_memRead : OUT std_logic;
    o_writeBack : OUT std_logic_vector(1 downto 0);
    o_readData : OUT std_logic_vector(31 downto 0);
    o_result : OUT std_logic_vector(31 downto 0);
    o_rdstAddr : OUT std_logic_vector(2 downto 0);
    o_rs2Addr : OUT std_logic_vector(2 downto 0);
    o_rs2Data : OUT std_logic_vector(31 downto 0);
    o_pc : OUT std_logic_vector(31 downto 0);
    o_exception : OUT std_logic
  );
END COMPONENT;

COMPONENT MEM_WB IS
  PORT (
    -- inputs
    i_clk : IN STD_LOGIC := '0';
    i_reset : IN STD_LOGIC := '0'; -- reset signal
    i_en : IN STD_LOGIC := '0';
    i_memRead : IN std_logic;
    i_writeBack : IN std_logic_vector(1 downto 0);
    i_readData : IN std_logic_vector(31 downto 0);
    i_result : IN std_logic_vector(31 downto 0);
    i_rdstAddr : IN std_logic_vector(2 downto 0);
    i_rs2Addr : IN std_logic_vector(2 downto 0);
    i_rs2Data : IN std_logic_vector(31 downto 0);
    -- outputs
    o_memRead : OUT std_logic;
    o_writeBack : OUT std_logic_vector(1 downto 0);
    o_readData : OUT std_logic_vector(31 downto 0);
    o_result : OUT std_logic_vector(31 downto 0);
    o_rdstAddr : OUT std_logic_vector(2 downto 0);
    o_rs2Addr : OUT std_logic_vector(2 downto 0);
    o_rs2Data : OUT std_logic_vector(31 downto 0)
  );
END COMPONENT MEM_WB;
SIGNAL w_MW_memRead_1, w_MW_memRead_2 : std_logic := '0';
SIGNAL w_MW_writeBack_1, w_MW_writeBack_2 : std_logic_vector(1 downto 0) := (others => '0');
SIGNAL w_MW_readData_1, w_MW_readData_2 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_MW_result_1, w_MW_result_2 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_MW_rdstAddr_1, w_MW_rdstAddr_2 : std_logic_vector(2 downto 0) := (others => '0');
SIGNAL w_MW_rs2Addr_1, w_MW_rs2Addr_2 : std_logic_vector(2 downto 0) := (others => '0');
SIGNAL w_MW_rs2Data_1, w_MW_rs2Data_2 : std_logic_vector(31 downto 0) := (others => '0');
-- ###################################

-- ###################################
COMPONENT WriteBack IS
  PORT(
    -- input signals
    i_memRead : IN std_logic;
    i_writeBack : IN std_logic_vector(1 downto 0);
    i_readData : IN std_logic_vector(31 downto 0);
    i_result : IN std_logic_vector(31 downto 0);
    i_rdstAddr : IN std_logic_vector(2 downto 0);
    i_rs2Addr : IN std_logic_vector(2 downto 0);
    i_rs2Data : IN std_logic_vector(31 downto 0);
    -- output signals
    o_writeBack : OUT std_logic_vector(1 downto 0);
    o_data : OUT std_logic_vector(31 downto 0);
    o_rdstAddr : OUT std_logic_vector(2 downto 0);
    o_rs2Addr : OUT std_logic_vector(2 downto 0);
    o_rs2Data : OUT std_logic_vector(31 downto 0)
  );
END COMPONENT;
SIGNAL w_WD_WB : std_logic_vector(1 downto 0) := (others => '0');
SIGNAL w_WD_data0 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_WD_data1 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_WD_address0 : std_logic_vector(2 downto 0) := (others => '0');
SIGNAL w_WD_address1 : std_logic_vector(2 downto 0) := (others => '0');
-- ###################################

COMPONENT BranchControl IS
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
END COMPONENT;
SIGNAL w_BF_WE : std_logic := '0';
SIGNAL w_BF_branchAddress : std_logic_vector(31 downto 0) := (others => '0');

COMPONENT ExceptionHandler IS
  PORT (
    -- inputs
    i_mem_violation : IN STD_LOGIC;
    i_overflow : IN STD_LOGIC;
    -- outputs
    o_exception : OUT STD_LOGIC;
    o_flush : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) -- 1 bit for memory (1), 1 bit for fetch and execute (1)
    -- 00 - no flush
    -- 01 - flush f/d d/e
    -- 11 - flush f/d d/e e/m
    -- 10 - XXX
  );
END COMPONENT;

COMPONENT ExceptionHandlerReg IS
  PORT (
    -- inputs
    i_we : IN STD_LOGIC;
    i_EPCMem : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- EPC for memory violation
    i_EPCExec : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- EPC for exception
    i_memory_violation : IN STD_LOGIC := '0';
    i_overflow : IN STD_LOGIC := '0';
    -- outputs
    o_EPCMem : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_EPCExec : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_exception_memory_violation : OUT STD_LOGIC;
    o_exception_overflow : OUT STD_LOGIC
  );
END COMPONENT;
SIGNAL w_EPCMem, w_EPCMem_2, w_EPCExe_2 : std_logic_vector(31 downto 0) := (others => '0');
SIGNAL w_MemException, w_MemException_2 : std_logic := '0';
SIGNAL w_ExeException, w_ExeException_2 : std_logic := '0';
SIGNAL w_ExF_exception : std_logic := '0';
SIGNAL w_Ex_flush : std_logic_vector(1 downto 0) := (others => '0');

BEGIN

F : Fetch PORT MAP (
    i_branch => w_BF_branchAddress,
    i_we => w_BF_WE,
    i_exception => w_ExF_exception,
    i_freeze => '0',-- TODO ,
    i_clk => i_clk,
    o_pc => w_FD_PC_1,
    o_instruction => w_FD_instruction_1,
    o_immediate => w_FD_immediate_1
);

FD : IF_ID PORT MAP (
    i_clk => i_clk,
    i_reset => i_reset OR w_Ex_flush(0),
    i_pc => w_FD_PC_1,
    i_en => '1',
    i_instruction => w_FD_instruction_1,
    i_immediate => w_FD_immediate_1,
    o_pc => w_FD_PC_2,
    o_instruction => w_FD_instruction_2,
    o_immediate => w_FD_immediate_2
);

D : DECODE PORT MAP(
    i_clk => i_clk,
    i_reset => i_reset,
    -- Input from fetch
    i_instruction => w_FD_instruction_2,
    i_immediate => w_FD_immediate_2,
    i_pc => w_FD_PC_2,
    -- Input from writeback (for register file)
    i_writeEnable => w_WD_WB,
    i_data0 => w_WD_data0,
    i_data1 => w_WD_data1,
    i_wbAddress0 => w_WD_address0,
    i_wbAddress1 => w_WD_address1,
    -- Input from HDU
    i_hduClearControl => '0', -- TODO
    -- Input from execution
    i_exeClearControl => w_Ex_flush(0),
    -- Output control signals
    o_WB => w_DE_WB_1,
    o_stackControl => w_DE_stackControl_1,
    o_memWrite => w_DE_memWrite_1,
    o_memRead => w_DE_memRead_1,
    o_inputEnable => w_DE_inputEnable_1,
    o_outputEnable => w_DE_outputEnable_1,
    o_isImm => w_DE_isImm_1,
    o_isProtect => w_DE_isProtect_1,
    o_isFree => w_DE_isFree_1,
    o_branchControl => w_DE_branchControl_1,
    -- Output signals from decode
    o_aluOP => w_DE_aluOP_1,
    o_vRs1 => w_DE_vRs1_1,
    o_vRs2 => w_DE_vRs2_1,
    o_vImmediate => w_DE_vImmediate_1,
    o_aRs1 => w_DE_aRs1_1,
    o_aRs2 => w_DE_aRs2_1,
    o_aRd => w_DE_aRd_1,
    -- Output no-logic wires
    o_pc => w_DE_PC_1
);

DE : ID_EX PORT MAP(
    i_clk => i_clk,
    i_reset => i_reset OR w_Ex_flush(0), -- ????? FLUSHHHH>>????
    i_en => '1',
    -- Input control signals
    i_WB => w_DE_WB_1,
    i_stackControl => w_DE_stackControl_1,
    i_memWrite => w_DE_memWrite_1,
    i_memRead => w_DE_memRead_1,
    i_inputEnable => w_DE_inputEnable_1,
    i_outputEnable => w_DE_outputEnable_1,
    i_isImm => w_DE_isImm_1,
    i_isProtect => w_DE_isProtect_1,
    i_isFree => w_DE_isFree_1,
    i_branchControl => w_DE_branchControl_1,
    -- Input signals from decode
    i_aluOP => w_DE_aluOP_1,
    i_vRs1 => w_DE_vRs1_1,
    i_vRs2 => w_DE_vRs2_1,
    i_vImmediate => w_DE_vImmediate_1,
    i_aRs1 => w_DE_aRs1_1,
    i_aRs2 => w_DE_aRs2_1,
    i_aRd => w_DE_aRd_1,
    -- Input no-logic wires
    i_pc => w_DE_PC_1,
    -- Output
    o_WB => w_DE_WB_2,
    o_stackControl => w_DE_stackControl_2,
    o_memWrite => w_DE_memWrite_2,
    o_memRead => w_DE_memRead_2,
    o_inputEnable => w_DE_inputEnable_2,
    o_outputEnable => w_DE_outputEnable_2,
    o_isImm => w_DE_isImm_2,
    o_isProtect => w_DE_isProtect_2,
    o_isFree => w_DE_isFree_2,
    o_branchControl => w_DE_branchControl_2,
    o_aluOP => w_DE_aluOP_2,
    o_vRs1 => w_DE_vRs1_2,
    o_vRs2 => w_DE_vRs2_2,
    o_vImmediate => w_DE_vImmediate_2,
    o_aRs1 => w_DE_aRs1_2,
    o_aRs2 => w_DE_aRs2_2,
    o_aRd => w_DE_aRd_2,
    -- Input no-logic wires
    o_pc => w_DE_PC_2
);

E : Execute PORT MAP(
    i_clk => i_clk,
    i_reset => i_reset,
    --control signals
    i_aluOp => w_DE_aluOP_2,
    i_inputEnable => w_DE_inputEnable_2,
    i_outputEnable => w_DE_outputEnable_2,
    i_isImm => w_DE_isImm_2,
    --input port
    i_inputPort => i_port,
    --data signals from decode
    i_vRs1 => w_DE_vRs1_2,
    i_vRs2 => w_DE_vRs2_2,
    i_immediate => w_DE_vImmediate_2,
    i_aRs1 => w_DE_aRs1_2,
    i_aRs2 => w_DE_aRs2_2,
    --data signals from memory
    i_vResult_ex => w_EM_aluResult,
    i_vRs2_ex => w_EM_vRs2,
    i_aRd_ex => w_EM_aRd,
    i_aRs2_ex => w_EM_aRs2,
    i_WB_ex => w_EM_WB,
    --data signals from write back
    i_vResult_mem => w_MW_result_2,
    i_vRs2_mem => w_MW_rs2Data_2,
    i_aRd_mem => w_MW_rdstAddr_2,
    i_aRs2_mem => w_MW_rs2Addr_2,
    i_WB_mem => w_MW_writeBack_2,
    --output signal out of here
    o_overflow => w_ExeException,
    o_result => w_EM_aluResult_1,
    o_output => o_port,
    o_vRs2 => w_EM_vRs2_1,
    o_flags => w_EM_flags_1
);

EM : EX_MEM PORT MAP(
    i_clk => i_clk,
    i_reset => i_reset OR w_Ex_flush(1),
    i_en => '1',
    -- Input control signals
    i_WB => w_DE_WB_2,
    i_stackControl => w_DE_stackControl_2,
    i_memWrite => w_DE_memWrite_2,
    i_memRead => w_DE_memRead_2,
    i_isProtect => w_DE_isProtect_2,
    i_isFree => w_DE_isFree_2,
    -- Input data signals
    i_aluResult => w_EM_aluResult_1,
    i_vRs2 => w_EM_vRs2_1,
    i_aRd => w_DE_aRd_2,
    i_aRs2 => w_DE_aRs2_2,
    i_pc => w_DE_PC_2,
    i_flag => w_EM_flags_1,
    --output signals
    o_memRead => w_EM_memRead,
    o_memWrite => w_EM_memWrite,
    o_WB => w_EM_WB,
    o_isProtect => w_EM_isProtect,
    o_isFree => w_EM_isFree,
    o_stackControl => w_EM_stackControl,
    -- data
    o_aluResult => w_EM_aluResult,
    o_vRs2 => w_EM_vRs2,
    o_aRd => w_EM_aRd,
    o_aRs2 => w_EM_aRs2,
    o_pc => w_EM_PC,
    o_flag => w_EM_flag
);

M : Memory PORT MAP(
    i_clk => i_clk,
    i_reset => i_reset,
    -- input from excute stage
    -- control signals
    i_memRead => w_EM_memRead,
    i_memWrite => w_EM_memWrite,
    i_writeBack => w_EM_WB,
    i_protect => w_EM_isProtect,
    i_free => w_EM_isFree,
    i_stackControl => w_EM_stackControl,
    -- data
    i_result => w_EM_aluResult,
    i_rdstAddr => w_EM_aRd,
    i_rs2Addr => w_EM_aRs2,
    i_rs2Data => w_EM_vRs2,
    i_pc => w_EM_PC,
    i_flag => w_EM_flag,
    -- output
    o_memRead => w_MW_memRead_1,
    o_writeBack => w_MW_writeBack_1,
    o_readData => w_MW_readData_1,
    o_result => w_MW_result_1,
    o_rdstAddr => w_MW_rdstAddr_1,
    o_rs2Addr => w_MW_rs2Addr_1,
    o_rs2Data => w_MW_rs2Data_1,
    o_pc => w_EPCMem,
    o_exception => w_MemException
);

MW : MEM_WB PORT MAP(
    -- inputs
    i_clk => i_clk,
    i_reset => i_reset,
    i_en => '1',
    i_memRead => w_MW_memRead_1,
    i_writeBack => w_MW_writeBack_1,
    i_readData => w_MW_readData_1,
    i_result => w_MW_result_1,
    i_rdstAddr => w_MW_rdstAddr_1,
    i_rs2Addr => w_MW_rs2Addr_1,
    i_rs2Data => w_MW_rs2Data_1,
    -- outputs
    o_memRead => w_MW_memRead_2,
    o_writeBack => w_MW_writeBack_2,
    o_readData => w_MW_readData_2,
    o_result => w_MW_result_2,
    o_rdstAddr => w_MW_rdstAddr_2,
    o_rs2Addr => w_MW_rs2Addr_2,
    o_rs2Data => w_MW_rs2Data_2
);


WB : WriteBack PORT MAP(
    -- input signals
    i_memRead => w_MW_memRead_2,
    i_writeBack => w_MW_writeBack_2,
    i_readData => w_MW_readData_2,
    i_result => w_MW_result_2,
    i_rdstAddr => w_MW_rdstAddr_2,
    i_rs2Addr => w_MW_rs2Addr_2,
    i_rs2Data => w_MW_rs2Data_2,
    -- output signals
    o_writeBack => w_WD_WB,
    o_data => w_WD_data0,
    o_rdstAddr => w_WD_address0,
    o_rs2Addr => w_WD_address1,
    o_rs2Data => w_WD_data1
);

BC : BranchControl PORT MAP(
    -- inputs
    i_branch_control => w_DE_branchControl_2,
    -- 00 = no branch, 01 = branch always (jmp), 10 = branch if equal (JZ), 11 = XXX
    i_branch_adress => w_EM_aluResult_1,
    i_z_flag => w_EM_flags_1(0),
    -- outputs
    o_branch_control => w_BF_WE,
    o_branch_adress => w_BF_branchAddress
);

ExH : ExceptionHandler PORT MAP(
    -- inputs
    i_mem_violation => w_MemException,
    i_overflow => w_ExeException,
    -- outputs
    o_exception => w_ExF_exception,
    o_flush => w_Ex_flush
    -- 00 - no flush
    -- 01 - flush fetch and execute
    -- 11 - flush fetch and execute and memory
    -- 10 - XXX
);

ExHReg : ExceptionHandlerReg PORT MAP(
    -- inputs
    i_we => '1',
    i_EPCMem => w_EPCMem,
    i_EPCExec => w_DE_PC_2,
    i_memory_violation => w_MemException,
    i_overflow => w_ExeException,
    -- outputs
    o_EPCMem => w_EPCMem_2, -- floating
    o_EPCExec => w_EPCExe_2, -- floating
    o_exception_memory_violation => w_MemException_2, -- floating
    o_exception_overflow => w_ExeException_2 -- floating
);

END ARCHITECTURE struct;