--this entity does not include branching
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
entity Execute is port(
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
    o_aluResult: out std_logic_vector(31 downto 0);
    o_result: out std_logic_vector(31 downto 0);
    o_output: out std_logic_vector(31 downto 0);
    o_vRs2: out std_logic_vector(31 downto 0)
);
end entity Execute;
architecture imp of Execute is
    component forwardUnit is port(
        i_rs1,i_rs2,i_rd_ex,i_rs2_ex,i_rd_mem,i_rs2_mem: in std_logic_vector(2 downto 0); --the addresses of the regs
        i_wb_ex,i_wb_mem: in std_logic_vector(1 downto 0); -- the writebacks
        o_selector1,o_selector2: out std_logic_vector(2 downto 0)
    );
    end component;
    component ALU is port(
        i_a,i_b: in std_logic_vector(31 downto 0);
        i_op: in std_logic_vector(3 downto 0);
        o_result: out std_logic_vector(31 downto 0);
        o_flags: out std_logic_vector(3 downto 0) --[3]overflow,[2]carry,[1]neg,[0]zero
    );
    end component;
    component FlagRegister is port(
        i_clk,i_rst: in std_logic;
        i_aluOp,i_flags: in std_logic_vector(3 downto 0);
        o_flags: out std_logic_vector(3 downto 0) --[3]overflow,[2]carry,[1]neg,[0]zero
    );
    end component;
    component outputPort is port(
        i_clk,i_rst,i_outputEnable: in std_logic;
        i_result: in std_logic_vector(31 downto 0);
        o_output: out std_logic_vector(31 downto 0) 
    );
    end component;
    signal s_selector1,s_selector2: std_logic_vector(2 downto 0);
    signal s_true_Rs1,s_true_Rs2: std_logic_vector(31 downto 0);
    signal s_second_operand: std_logic_vector(31 downto 0);
    signal s_result_alu: std_logic_vector(31 downto 0);
    signal s_flags_alu: std_logic_vector(3 downto 0);
    signal s_true_Result: std_logic_vector(31 downto 0);
    signal s_flags: std_logic_vector(3 downto 0);
begin
    forward:forwardUnit port map(i_aRs1,i_aRs2,i_aRd_ex,i_aRs2_ex,i_aRd_mem,i_aRs2_mem,i_WB_ex,i_WB_mem,s_selector1,s_selector2);
    alu1:ALU port map(s_true_Rs1,s_second_operand,i_aluOp,s_result_alu,s_flags_alu);
    flag:FlagRegister port map(i_clk,i_reset,i_aluOp,s_flags_alu,s_flags);
    output:outputPort port map(i_clk,i_reset,i_outputEnable,s_result_alu,o_output);
    s_true_Rs1 <= i_vRs1 when s_selector1 = "000" else --First forwarding mux
                    i_vResult_ex when s_selector1 = "001" else
                    i_vRs2_ex when s_selector1 = "010" else
                    i_vResult_mem when s_selector1 = "011" else
                    i_vRs2_mem;
    s_true_Rs2 <= i_vRs1 when s_selector2 = "000" else --Second forwarding mux
                    i_vResult_ex when s_selector2 = "001" else
                    i_vRs2_ex when s_selector2 = "010" else
                    i_vResult_mem when s_selector2 = "011" else
                    i_vRs2_mem;
    s_second_operand <= s_true_Rs2 when i_isImm = '0' else i_immediate;--Immediate or Rs2 mux
    o_result<= s_result_alu when i_inputEnable = '0' else i_inputPort; --Output mux
    o_aluResult<= s_result_alu;
    o_overflow<= s_flags(3);
    o_vRs2<= s_true_Rs2;



end imp;
