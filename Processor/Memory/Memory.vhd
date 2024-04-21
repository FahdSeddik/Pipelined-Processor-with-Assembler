LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY Memory IS
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
        i_stackControl : OUT std_logic_vector(1 downto 0);
        i_flush : IN std_logic;
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
        o_exception : OUT std_logic;
        o_isRTI : OUT std_logic

    );
END Memory;

ARCHITECTURE Behavior OF Memory IS
    
    COMPONENT DataMemory IS
        PORT(
            i_clk : IN std_logic;
            i_memWrite  : IN std_logic;  -- write enable
            i_memRead : IN std_logic; -- read enable
            i_protect : IN  std_logic; -- protect bit
            i_free : IN  std_logic; -- free bit
            i_address : IN  std_logic_vector(31 DOWNTO 0);
            i_dataIn  : IN  std_logic_vector(31 DOWNTO 0);
            o_dataOut : OUT std_logic_vector(31 DOWNTO 0);
            o_exception : OUT std_logic  -- 0 = no exception, 1 = address out of range or protected address
        );
    END COMPONENT;

    COMPONENT StackPointer IS
        PORT( 
            i_clk: IN std_logic;
            i_rst: IN std_logic;
            i_push: IN std_logic;
            i_pop: IN std_logic;
            o_q : OUT std_logic_vector(31 DOWNTO 0)
        );
    END COMPONENT;
    

    signal s_address : std_logic_vector(31 downto 0);
    signal s_stachPointer : std_logic_vector(31 downto 0);
    -- signal s_exception : std_logic_vector(1 downto 0);
    signal s_push : std_logic;
    signal s_pop : std_logic;
    signal s_dataIn : std_logic_vector(31 downto 0);
    signal s_isRTI : std_logic;
    signal s_stackControl : std_logic_vector(1 downto 0);

    BEGIN
        s_isRTI <= '1' when i_stackControl = "11" else '0';
        s_stackControl <= (i_stackControl(1) xor s_isRTI) & i_stackControl(0);
        s_address <= i_result when s_stackControl = "00" else s_stachPointer;
        s_push <= '1' when s_stackControl /= "00" and i_writeBack(1) = '0' else '0';
        s_pop <= '1' when s_stackControl /= "00" and i_writeBack(1) = '1' else '0';
        -- data in is result in normal cases when i_stackControl = "00" 
        -- and it is the pc in cases of ret and call instructions, i_stackControl = "01"
        -- and it is the flag reg in when i_stackControl = "11"
        -- rti and int are "11" then "01"
        s_dataIn <= i_pc when s_stackControl = "01"
                    -- flag register (4 bits) padded with 28 zeros
                    else (0 to 27 => '0') & i_flag when s_stackControl = "11"
                    else i_result;
                     


        DataMemory1: DataMemory PORT MAP(
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

        StackPointer1: StackPointer PORT MAP(
            i_clk => i_clk,
            i_rst => i_reset,
            i_push => s_push,
            i_pop => s_pop,
            o_q => s_stachPointer
        );

        o_memRead <= i_memRead;
        o_writeBack <= i_writeBack;
        o_result <= i_result;
        o_rdstAddr <= i_rdstAddr;
        o_rs2Addr <= i_rs2Addr;
        o_rs2Data <= i_rs2Data;
        o_isRTI <= s_isRTI;
        o_pc <= i_pc;

END Behavior;
