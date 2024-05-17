LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Bit_Predictor IS
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
END Bit_Predictor;
ARCHITECTURE imp OF Bit_Predictor IS
    SIGNAL s_prediction : STD_LOGIC := '0';
BEGIN
    o_prediction <= '0' WHEN (i_Ex_wb(1) = '1' AND i_Ex_aRd = i_aRs1) OR(i_Mem_wb(1) = '1' AND i_Mem_aRd = i_aRs1) OR i_branch_control = "00"
        ELSE
        '1' WHEN i_branch_control = "11" OR i_branch_control = "01"
        ELSE
        s_prediction;
    o_address <= i_vRs1;
    PROCESS (i_clk) IS BEGIN
        IF rising_edge(i_clk) THEN
            IF i_branch_control = "11" OR i_branch_control = "01" THEN
                s_prediction <= '1';
            ELSE
                s_prediction <= s_prediction XOR i_branched;
            END IF;
        END IF;
    END PROCESS;

END imp;