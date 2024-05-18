LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Processor IS
  PORT (
    i_clk : IN STD_LOGIC;
    i_reset : IN STD_LOGIC;
    i_interrupt : IN STD_LOGIC;
    i_port : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END ENTITY;
ARCHITECTURE struct OF Processor IS
  -- Fetch, Reg, Decode, Reg, Ex, Reg, Mem, Reg, Wb
  -- Exception handling, Branch control
  -- ###################################
  COMPONENT Fetch IS
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
  END COMPONENT;

  COMPONENT IF_ID IS
    PORT (
      -- inputs
      i_clk : IN STD_LOGIC := '0';
      i_reset : IN STD_LOGIC := '0';
      i_en : IN STD_LOGIC := '0';
      i_flush : IN STD_LOGIC := '0';
      i_int : IN STD_LOGIC := '0';
      i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      i_instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
      i_immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
      -- outputs
      o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      o_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
      o_int : OUT STD_LOGIC := '0';
      o_immediate : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
    );
  END COMPONENT;
  SIGNAL w_FD_int : STD_LOGIC := '0';
  SIGNAL w_FD_PC_1, w_FD_PC_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_FD_instruction_1, w_FD_instruction_2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_FD_immediate_1, w_FD_immediate_2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  -- ###################################

  -- ###################################
  COMPONENT DECODE IS
    PORT (
      i_clk : IN STD_LOGIC := '0';
      i_reset : IN STD_LOGIC := '0';
      -- Input from fetch
      i_instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); --for decoding
      i_immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); --for sign extend
      i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); --no-logic signal
      -- Input from writeback (for register file)
      i_writeEnable : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- i_writeEnable[1]->normal i_writeEnable[0]->on if swap
      i_data0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); --normally if wb[1]
      i_data1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); --to address 0 and 0 to address 1 if swap
      i_wbAddress0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      i_wbAddress1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      -- Input from HDU
      i_hduClearControl : IN STD_LOGIC := '0';
      -- Input from execution
      i_exeClearControl : IN STD_LOGIC := '0';
      -- Input from branch handler
      i_branchAddress : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      -- Input from Interrupt handler
      i_forwardPC : IN STD_LOGIC := '0';
      -- Output control signals
      o_WB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
      o_stackControl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); --to determine what types of stack instructions is needed
      o_memWrite : OUT STD_LOGIC := '0'; --store
      o_memRead : OUT STD_LOGIC := '0'; --load
      o_inputEnable : OUT STD_LOGIC := '0'; --on in
      o_outputEnable : OUT STD_LOGIC := '0'; --on out
      o_isImm : OUT STD_LOGIC := '0'; -- bit in instruction
      o_isProtect : OUT STD_LOGIC := '0';
      o_isFree : OUT STD_LOGIC := '0';
      o_branchControl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
      -- Output signals from decode
      o_aluOP : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
      o_vRs1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      o_vRs2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      o_vImmediate : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      o_aRs1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      o_aRs2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      o_aRd : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      -- Output no-logic wires
      o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
    );
  END COMPONENT;

  COMPONENT ID_EX IS
    PORT (
      i_clk, i_reset, i_en, i_flush : IN STD_LOGIC := '0';
      -- Input control signals
      i_WB : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
      i_stackControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); --to determine what types of stack instructions is needed
      i_int : IN STD_LOGIC := '0'; --interrupt
      i_memWrite : IN STD_LOGIC := '0'; --store
      i_memRead : IN STD_LOGIC := '0'; --load
      i_inputEnable : IN STD_LOGIC := '0'; --on in
      i_outputEnable : IN STD_LOGIC := '0'; --on out
      i_isImm : IN STD_LOGIC := '0'; -- bit in instruction
      i_isProtect : IN STD_LOGIC := '0';
      i_isFree : IN STD_LOGIC := '0';
      i_branchControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
      -- Input signals from decode
      i_branchPredict : IN STD_LOGIC := '0';
      i_aluOP : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
      i_vRs1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      i_vRs2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      i_vImmediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      i_aRs1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      i_aRs2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      i_aRd : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      -- Input no-logic wires
      i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      -- Output ### ADD SEMI-COLON ABOVE
      o_bitpredict : OUT STD_LOGIC := '0';
      o_WB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
      o_stackControl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
      o_memWrite : OUT STD_LOGIC := '0';
      o_memRead : OUT STD_LOGIC := '0';
      o_inputEnable : OUT STD_LOGIC := '0';
      o_outputEnable : OUT STD_LOGIC := '0';
      o_isImm : OUT STD_LOGIC := '0';
      o_isProtect : OUT STD_LOGIC := '0';
      o_isFree : OUT STD_LOGIC := '0';
      o_branchControl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
      o_aluOP : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
      o_vRs1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      o_vRs2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      o_vImmediate : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      o_aRs1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      o_aRs2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      o_aRd : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      o_int : OUT STD_LOGIC := '0'; --interrupt
      -- Input no-logic wires
      o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
    );
  END COMPONENT;
  SIGNAL w_DE_int : STD_LOGIC := '0';
  SIGNAL w_DE_WB_1, w_DE_WB_2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_stackControl_1, w_DE_stackControl_2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_memWrite_1, w_DE_memWrite_2 : STD_LOGIC := '0';
  SIGNAL w_DE_memRead_1, w_DE_memRead_2 : STD_LOGIC := '0';
  SIGNAL w_DE_inputEnable_1, w_DE_inputEnable_2 : STD_LOGIC := '0';
  SIGNAL w_DE_outputEnable_1, w_DE_outputEnable_2 : STD_LOGIC := '0';
  SIGNAL w_DE_isImm_1, w_DE_isImm_2 : STD_LOGIC := '0';
  SIGNAL w_DE_isProtect_1, w_DE_isProtect_2 : STD_LOGIC := '0';
  SIGNAL w_DE_isFree_1, w_DE_isFree_2 : STD_LOGIC := '0';
  SIGNAL w_DE_branchControl_1, w_DE_branchControl_2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_aluOP_1, w_DE_aluOP_2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_vRs1_1, w_DE_vRs1_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_vRs2_1, w_DE_vRs2_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_vImmediate_1, w_DE_vImmediate_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_aRs1_1, w_DE_aRs1_2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_aRs2_1, w_DE_aRs2_2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_aRd_1, w_DE_aRd_2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_PC_1, w_DE_PC_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_DE_branchPredict : STD_LOGIC := '0';
  -- ###################################

  -- ###################################
  COMPONENT Execute IS PORT (
    i_clk, i_reset : IN STD_LOGIC;
    --control signals
    i_aluOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    i_branchControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    i_inputEnable, i_outputEnable : IN STD_LOGIC;
    i_isImm : IN STD_LOGIC;
    --input port
    i_inputPort : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    --data signals from decode
    i_vRs1, i_vRs2, i_immediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_aRs1, i_aRs2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    --data signals from memory
    i_vResult_ex, i_vRs2_ex : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_aRd_ex, i_aRs2_ex : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    i_WB_ex : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    --data signals from write back
    i_vResult_mem, i_vRs2_mem : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_aRd_mem, i_aRs2_mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    i_WB_mem : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    --output signal out of here
    o_overflow : OUT STD_LOGIC;
    o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_vRs2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    o_flags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
  END COMPONENT Execute;

  COMPONENT EX_MEM IS
    PORT (
      i_clk, i_reset, i_en, i_flush : IN STD_LOGIC := '0';
      -- Input control signals
      i_WB : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- o_WB[1]->normal o_WB[0]->on if swap
      i_stackControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); --to determine what types of stack instructions is needed
      i_memWrite : IN STD_LOGIC := '0'; --store
      i_memRead : IN STD_LOGIC := '0'; --load
      i_isProtect : IN STD_LOGIC := '0';
      i_isFree : IN STD_LOGIC := '0';
      i_int : IN STD_LOGIC := '0';
      -- Input data signals
      i_aluResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      i_vRs2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      i_aRd : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      i_aRs2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
      i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      i_flag : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
      --output signals
      o_memRead : OUT STD_LOGIC;
      o_memWrite : OUT STD_LOGIC;
      o_WB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- i_writeEnable[1]->normal i_writeEnable[0]->on if swap
      o_isProtect : OUT STD_LOGIC;
      o_isFree : OUT STD_LOGIC;
      o_stackControl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      -- data
      o_aluResult : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU result
      o_vRs2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_aRd : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_aRs2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_flag : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      o_int : OUT STD_LOGIC
    );
  END COMPONENT EX_MEM;
  SIGNAL w_EM_int : STD_LOGIC := '0';
  SIGNAL w_EM_aluResult_1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_vRs2_1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_flags_1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_memRead : STD_LOGIC := '0';
  SIGNAL w_EM_memWrite : STD_LOGIC := '0';
  SIGNAL w_EM_WB : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_isProtect : STD_LOGIC := '0';
  SIGNAL w_EM_isFree : STD_LOGIC := '0';
  SIGNAL w_EM_stackControl : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_aluResult : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_vRs2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_aRd : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_aRs2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_PC : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_EM_flag : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  -- ###################################

  -- ###################################
  COMPONENT Memory IS
    PORT (
      i_clk : IN STD_LOGIC;
      i_reset : IN STD_LOGIC;
      -- input from excute stage
      -- control signals
      i_memRead : IN STD_LOGIC;
      i_memWrite : IN STD_LOGIC;
      i_writeBack : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- i_writeEnable[1]->normal i_writeEnable[0]->on if swap
      i_protect : IN STD_LOGIC;
      i_free : IN STD_LOGIC;
      i_stackControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      -- data
      i_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- ALU result
      i_rdstAddr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_rs2Addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_rs2Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_flag : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      -- output
      o_memRead : OUT STD_LOGIC;
      o_writeBack : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      o_readData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_rdstAddr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_rs2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_rs2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_exception : OUT STD_LOGIC;
      o_return : OUT STD_LOGIC;
      o_interruptType : OUT STD_LOGIC;
      o_flush : OUT STD_LOGIC;
      o_freeze : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT MEM_WB IS
    PORT (
      -- inputs
      i_clk : IN STD_LOGIC := '0';
      i_reset : IN STD_LOGIC := '0'; -- reset signal
      i_en : IN STD_LOGIC := '0';
      i_flush : IN STD_LOGIC := '0';
      i_memRead : IN STD_LOGIC;
      i_writeBack : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      i_readData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_rdstAddr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_rs2Addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_rs2Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      -- outputs
      o_memRead : OUT STD_LOGIC;
      o_writeBack : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      o_readData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_rdstAddr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_rs2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_rs2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT MEM_WB;
  SIGNAL w_MW_int : STD_LOGIC := '0';
  SIGNAL w_MW_memRead_1, w_MW_memRead_2 : STD_LOGIC := '0';
  SIGNAL w_MW_writeBack_1, w_MW_writeBack_2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_MW_readData_1, w_MW_readData_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_MW_result_1, w_MW_result_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_MW_rdstAddr_1, w_MW_rdstAddr_2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_MW_rs2Addr_1, w_MW_rs2Addr_2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_MW_rs2Data_1, w_MW_rs2Data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  -- ###################################

  -- ###################################
  COMPONENT WriteBack IS
    PORT (
      -- input signals
      i_memRead : IN STD_LOGIC;
      i_writeBack : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      i_readData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_rdstAddr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_rs2Addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_rs2Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      -- output signals
      o_writeBack : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      o_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_rdstAddr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_rs2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      o_rs2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;
  SIGNAL w_WD_WB : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_WD_data0 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_WD_data1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_WD_address0 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_WD_address1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  -- ###################################

  COMPONENT BranchControl IS
    PORT (
      -- inputs
      i_clk : IN STD_LOGIC;
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
  END COMPONENT;
  SIGNAL w_BF_WE : STD_LOGIC := '0';
  SIGNAL w_BF_branchAddress : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  COMPONENT Bit_Predictor IS
    PORT (
      i_clk : IN STD_LOGIC;
      i_aRs1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_vRs1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_branch_control : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      i_branched : IN STD_LOGIC;
      i_Ex_wb : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      i_Ex_aRd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_Mem_wb : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      i_Mem_aRd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      --outputs
      o_prediction : OUT STD_LOGIC;
      o_address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;
  SIGNAL w_BP_prediction : STD_LOGIC := '0';
  SIGNAL w_BP_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  COMPONENT HazardDetector IS
    PORT (
      i_aRs1, i_aRs2, i_aRd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      i_aMemRead : IN STD_LOGIC;
      o_Hazard : OUT STD_LOGIC
    );
  END COMPONENT;
  SIGNAL w_Hazard : STD_LOGIC := '0';

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
  SIGNAL w_EPCMem, w_EPCMem_2, w_EPCExe_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
  SIGNAL w_MemException, w_MemException_2 : STD_LOGIC := '0';
  SIGNAL w_MemReturn, w_MeminterruptType, w_MemFlush, w_MemFreeze : STD_LOGIC := '0';
  SIGNAL w_ExeException, w_ExeException_2 : STD_LOGIC := '0';
  SIGNAL w_ExF_exception : STD_LOGIC := '0';
  SIGNAL w_Ex_flush : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  --flushing signals
  SIGNAL w_FD_flush, w_DE_flush, w_EM_flush, w_MW_flush : STD_LOGIC := '0';

BEGIN

  F : Fetch PORT MAP(
    i_branch_address => w_BF_branchAddress,
    i_branch_we => w_BF_WE,
    i_forward_pc => w_BF_WE,
    i_predict_we => w_BP_prediction,
    i_predict_address => w_BP_address,
    i_freeze => w_Hazard, -- TODO ,
    i_interrupt => i_interrupt,
    i_exception => w_ExF_exception,
    i_clk => i_clk,
    i_reset => i_reset,
    o_pc => w_FD_PC_1,
    o_instruction => w_FD_instruction_1,
    o_immediate => w_FD_immediate_1
  );

  FD : IF_ID PORT MAP(
    i_clk => i_clk,
    i_reset => i_reset,
    i_pc => w_FD_PC_1,
    i_en => NOT w_Hazard,
    i_flush => w_FD_flush,
    i_int => i_interrupt,
    i_instruction => w_FD_instruction_1,
    i_immediate => w_FD_immediate_1,
    o_pc => w_FD_PC_2,
    o_instruction => w_FD_instruction_2,
    o_immediate => w_FD_immediate_2,
    o_int => w_FD_int
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
    -- Input from branch handler
    i_branchAddress => w_BF_branchAddress,
    -- Input from Interrupt handler
    i_forwardPC => w_BF_WE,
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
    i_flush => w_DE_flush, --replace with flush expression
    i_int => w_FD_int,
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
    i_branchPredict => w_BP_prediction,
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
    o_bitpredict => w_DE_branchPredict,
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
    o_int => w_DE_int,
    -- Input no-logic wires
    o_pc => w_DE_PC_2
  );

  E : Execute PORT MAP(
    i_clk => i_clk,
    i_reset => i_reset,
    --control signals
    i_aluOp => w_DE_aluOP_2,
    i_branchControl => w_DE_branchControl_2,
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
    i_vResult_mem => w_WD_data0,
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
    i_flush => w_EM_flush, --replace with flush expression
    -- Input control signals
    i_WB => w_DE_WB_2,
    i_stackControl => w_DE_stackControl_2,
    i_memWrite => w_DE_memWrite_2,
    i_memRead => w_DE_memRead_2,
    i_isProtect => w_DE_isProtect_2,
    i_isFree => w_DE_isFree_2,
    i_int => w_DE_int,
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
    o_flag => w_EM_flag,
    o_int => w_EM_int
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
    o_exception => w_MemException,
    o_return => w_MemReturn,
    o_interruptType => w_MeminterruptType,
    o_flush => w_MemFlush,
    o_freeze => w_MemFreeze
  );

  MW : MEM_WB PORT MAP(
    -- inputs
    i_clk => i_clk,
    i_reset => i_reset,
    i_en => '1',
    i_flush => w_MW_flush, --replace with flush expression
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
  BP : Bit_Predictor PORT MAP(
    i_clk => i_clk,
    i_aRs1 => w_DE_aRs1_1,
    i_vRs1 => w_DE_vRs1_1,
    i_branch_control => w_DE_branchControl_1,
    i_branched => w_BF_WE,
    i_Ex_wb => w_DE_WB_2,
    i_Ex_aRd => w_DE_aRd_2,
    i_Mem_wb => w_EM_WB,
    i_Mem_aRd => w_EM_aRd,
    o_prediction => w_BP_prediction, --TODO
    o_address => w_BP_address --TODO
  );
  BC : BranchControl PORT MAP(
    -- inputs
    i_clk => i_clk,
    i_branch_control => w_DE_branchControl_2,
    -- 00 = no branch, 01 = branch always (jmp), 10 = branch if equal (JZ), 11 = call
    i_alu_res => w_EM_aluResult_1,
    i_pc => w_DE_PC_2,
    i_bit_predictor => w_DE_branchPredict,
    i_z_flag => w_EM_flags_1(0),
    i_return => w_MemReturn,
    i_branch_adress => w_MW_readData_1,
    -- outputs
    o_branch_control => w_BF_WE,
    o_branch_adress => w_BF_branchAddress
  );
  HD : HazardDetector PORT MAP(
    i_aRs1 => w_DE_aRs1_1,
    i_aRs2 => w_DE_aRs2_1,
    i_aRd => w_DE_aRd_2,
    i_aMemRead => w_DE_memRead_2,
    o_Hazard => w_Hazard
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
  w_FD_flush <= w_BP_prediction OR w_BF_WE;
  w_DE_flush <= w_BF_WE OR w_Ex_flush(0) OR w_Hazard;
  w_EM_flush <= w_Ex_flush(1) OR w_MemFlush;
  w_MW_flush <= '0';

END ARCHITECTURE struct;