--Takes 2 inputs other than the clock and reset, which are i_aluOp from DEC/EX reg, and i_flags from ALU
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_signed.ALL;
ENTITY FlagRegister IS PORT (
    i_clk, i_rst : IN STD_LOGIC;
    i_pop_flags : IN STD_LOGIC;
    i_mem_flags : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    i_aluOp, i_flags : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    i_branchControl : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    o_flags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) --[3]overflow,[2]carry,[1]neg,[0]zero
);
END FlagRegister;
ARCHITECTURE imp OF FlagRegister IS
    SIGNAL flags : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    PROCESS (i_clk, i_rst) IS BEGIN
        IF i_rst = '1' THEN
            flags <= "0000";
        ELSIF falling_edge(i_clk) THEN --TODO check assumption on edge of other regs (currently assuming rising)
            IF i_aluOp(3) = '1' THEN
                flags(3 DOWNTO 2) <= i_flags(3 DOWNTO 2);
            END IF;
            IF (i_aluOp(2) = '1') OR (i_aluOp(3) = '1') THEN
                flags(1 DOWNTO 0) <= i_flags(1 DOWNTO 0);
            END IF;
        ELSIF rising_edge(i_clk) THEN
            IF i_branchControl = "10" THEN
                flags(0) <= '0';
            END IF;
            IF i_pop_flags = '1' THEN
                flags <= i_mem_flags;
            END IF;
        END IF;
    END PROCESS;
    o_flags <= flags;
END imp;