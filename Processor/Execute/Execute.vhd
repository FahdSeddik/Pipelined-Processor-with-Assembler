--this entity does not include branching
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_signed.ALL;
ENTITY Execute IS PORT (
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
    i_pop_flag : IN STD_LOGIC;
    i_mem_flag : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
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
END ENTITY Execute;
ARCHITECTURE imp OF Execute IS
    COMPONENT forwardUnit IS PORT (
        i_rs1, i_rs2, i_rd_ex, i_rs2_ex, i_rd_mem, i_rs2_mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0); --the addresses of the regs
        i_wb_ex, i_wb_mem : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- the writebacks
        o_selector1, o_selector2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT ALU IS PORT (
        i_a, i_b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_op : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_flags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) --[3]overflow,[2]carry,[1]neg,[0]zero
        );
    END COMPONENT;
    COMPONENT FlagRegister IS PORT (
        i_clk, i_rst : IN STD_LOGIC;
        i_pop_flags : IN STD_LOGIC;
        i_mem_flags : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        i_aluOp, i_flags : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        i_branchControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        o_flags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) --[3]overflow,[2]carry,[1]neg,[0]zero
        );
    END COMPONENT;
    COMPONENT outputPort IS PORT (
        i_clk, i_rst, i_outputEnable : IN STD_LOGIC;
        i_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    SIGNAL s_selector1, s_selector2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL s_true_Rs1, s_true_Rs2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_second_operand : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_result_alu : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_flags_alu : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL s_flags : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    forward : forwardUnit PORT MAP(i_aRs1, i_aRs2, i_aRd_ex, i_aRs2_ex, i_aRd_mem, i_aRs2_mem, i_WB_ex, i_WB_mem, s_selector1, s_selector2);
    alu1 : ALU PORT MAP(s_true_Rs1, s_second_operand, i_aluOp, s_result_alu, s_flags_alu);
    flag : FlagRegister PORT MAP(i_clk, i_reset, i_pop_flag, i_mem_flag, i_aluOp, s_flags_alu, i_branchControl, s_flags);
    output : outputPort PORT MAP(i_clk, i_reset, i_outputEnable, s_result_alu, o_output);
    s_true_Rs1 <= i_vRs1 WHEN s_selector1 = "000" ELSE --First forwarding mux
        i_vResult_ex WHEN s_selector1 = "001" ELSE
        i_vRs2_ex WHEN s_selector1 = "010" ELSE
        i_vResult_mem WHEN s_selector1 = "011" ELSE
        i_vRs2_mem;
    s_true_Rs2 <= i_vRs2 WHEN s_selector2 = "000" ELSE --Second forwarding mux
        i_vResult_ex WHEN s_selector2 = "001" ELSE
        i_vRs2_ex WHEN s_selector2 = "010" ELSE
        i_vResult_mem WHEN s_selector2 = "011" ELSE
        i_vRs2_mem;
    s_second_operand <= s_true_Rs2 WHEN i_isImm = '0' ELSE
        i_immediate;--Immediate or Rs2 mux
    o_result <= s_result_alu WHEN i_inputEnable = '0' ELSE
        i_inputPort; --Output mux
    o_overflow <= s_flags(3);
    o_vRs2 <= s_true_Rs2;
    o_flags <= s_flags;
END imp;