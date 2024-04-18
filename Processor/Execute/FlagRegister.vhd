--Takes 2 inputs other than the clock and reset, which are i_aluOp from DEC/EX reg, and i_flags from ALU
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
entity FlagRegister is port(
    i_clk,i_rst: in std_logic;
    i_aluOp,i_flags: in std_logic_vector(3 downto 0);
    o_flags: out std_logic_vector(3 downto 0) --[3]overflow,[2]carry,[1]neg,[0]zero
);
end FlagRegister;
architecture imp of FlagRegister is
    signal flags: std_logic_vector(3 downto 0);
begin
    process(i_clk,i_rst) is begin
        if i_rst='1' then
            flags<="0000";
        elsif falling_edge(i_clk) then --TODO check assumption on edge of other regs (currently assuming rising)
            if i_aluOp(3)='1' then 
                flags(3 downto 2)<=i_flags(3 downto 2);
            end if;
            if (i_aluOp(2)='1') or (i_aluOp(3)='1') then
                flags(1 downto 0)<=i_flags(1 downto 0);
            end if;
        end if;
    end process;
    o_flags<=flags;
end imp;