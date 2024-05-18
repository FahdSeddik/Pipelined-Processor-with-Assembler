LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;


ENTITY Memory IS
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
END Memory;

ARCHITECTURE Behavior OF Memory IS

    COMPONENT DataMemory IS
        PORT (
            i_clk : IN STD_LOGIC;
            i_memWrite : IN STD_LOGIC; -- write enable
            i_memRead : IN STD_LOGIC; -- read enable
            i_protect : IN STD_LOGIC; -- protect bit
            i_free : IN STD_LOGIC; -- free bit
            i_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_dataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_dataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_exception : OUT STD_LOGIC -- 0 = no exception, 1 = address out of range or protected address
        );
    END COMPONENT;

    COMPONENT StackPointer IS
        PORT (
            i_clk : IN STD_LOGIC;
            i_rst : IN STD_LOGIC;
            i_push : IN STD_LOGIC;
            i_pop : IN STD_LOGIC;
            o_q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    SIGNAL s_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_stachPointer : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_push : STD_LOGIC;
    SIGNAL s_pop : STD_LOGIC;
    SIGNAL s_dataIn : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_interruptType : STD_LOGIC := '0';
    -- signal s_stackControl : std_logic_vector(1 downto 0);

BEGIN
    PROCESS (i_clk)
    BEGIN
        IF rising_edge(i_clk) THEN
            IF s_interruptType = '1' THEN
                s_interruptType <= '0';
            ELSIF i_stackControl = "11" THEN
                s_interruptType <= '1';
            END IF;
        END IF;
    END PROCESS;

    -- s_stackControl <= (i_stackControl(1) xor s_interruptType) & i_stackControl(0);
    s_address <= i_result WHEN i_stackControl = "00" ELSE
        s_stachPointer;
    s_push <= '1' WHEN i_stackControl /= "00" AND i_writeBack(1) = '0' ELSE
        '0';
    s_pop <= '1' WHEN i_stackControl /= "00" AND i_writeBack(1) = '1' ELSE
        '0';

    -- dataIn is the data to be written to memory. PC when stackControl = 01 or 11, flag register when stackControl = 11 and s_interruptType = 1, rs2Data otherwise
    s_dataIn <= i_pc+1 WHEN (i_stackControl = "11" AND s_interruptType /= '1') OR i_stackControl = "01" ELSE
        x"0000000" & i_flag WHEN (i_stackControl = "11" AND s_interruptType = '1')
        ELSE
        i_rs2Data;
    DataMemory1 : DataMemory PORT MAP(
        i_clk => i_clk,
        i_memWrite => i_memWrite,
        i_memRead => i_memRead,
        i_protect => i_protect,
        i_free => i_free,
        i_address => s_address,
        i_dataIn => s_dataIn,
        o_dataOut => o_readData,
        o_exception => o_exception
    );

    StackPointer1 : StackPointer PORT MAP(
        i_clk => i_clk,
        i_rst => i_reset,
        i_push => s_push,
        i_pop => s_pop,
        o_q => s_stachPointer
    );

    o_memRead <= i_memRead;
    o_writeBack <= i_writeBack WHEN not i_stackControl(0) ELSE
        "00";
    o_result <= i_result;
    o_rdstAddr <= i_rdstAddr;
    o_rs2Addr <= i_rs2Addr;
    o_rs2Data <= i_rs2Data;
    o_pc <= i_pc;
    o_return <= i_stackControl(0) AND i_writeBack(1) AND NOT s_interruptType;
    o_interruptType <= s_interruptType;
    o_freeze <= '1' WHEN (i_stackControl = "11" AND s_interruptType = '0') ELSE
        '0';
    o_flush <= '1' WHEN (i_stackControl = "11" AND s_interruptType = '1') OR i_stackControl = "01" ELSE
        '0';
END Behavior;