-- Forwarding Unit take from ex/mem reg and mem/wb reg for forwarding
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
entity forwardUnit is port(
    i_rs1,i_rs2,i_rd_ex,i_rs2_ex,i_rd_mem,i_rs2_mem: in std_logic_vector(2 downto 0); --the addresses of the regs
    i_wb_ex,i_wb_mem: in std_logic_vector(1 downto 0); -- the writebacks
    o_selector1,o_selector2: out std_logic_vector(2 downto 0)
);
end forwardUnit;
architecture imp of forwardUnit is begin
    o_selector1 <= "010" when (i_rs1 = i_rd_ex) and ((i_wb_ex(1)='1') and (i_wb_ex(0)='1')) else
                   "001" when (i_rs1 = i_rs2_ex) and ((i_wb_ex(1)='1') and (i_wb_ex(0)='1')) else
                   "001" when (i_rs1 = i_rd_ex) and (i_wb_ex(1)='1') else
                   "100" when (i_rs1 = i_rd_mem) and ((i_wb_mem(1)='1') and (i_wb_mem(0)='1')) else
                   "011" when (i_rs1 = i_rs2_mem) and ((i_wb_mem(1)='1') and (i_wb_mem(0)='1')) else
                   "011" when (i_rs1 = i_rd_mem) and (i_wb_mem(1)='1') else
                   "000";
    o_selector2 <= "010" when (i_rs2 = i_rd_ex) and ((i_wb_ex(1)='1') and (i_wb_ex(0)='1')) else
                   "001" when (i_rs2 = i_rs2_ex) and ((i_wb_ex(1)='1') and (i_wb_ex(0)='1')) else
                   "001" when (i_rs2 = i_rd_ex) and (i_wb_ex(1)='1') else
                   "100" when (i_rs2 = i_rd_mem) and ((i_wb_mem(1)='1') and (i_wb_mem(0)='1')) else
                   "011" when (i_rs2 = i_rs2_mem) and ((i_wb_mem(1)='1') and (i_wb_mem(0)='1')) else
                   "011" when (i_rs2 = i_rd_mem) and (i_wb_mem(1)='1') else
                   "000";


    end imp;