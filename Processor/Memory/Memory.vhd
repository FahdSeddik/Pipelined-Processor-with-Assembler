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
        o_return : OUT std_logic
        o_interruptType : OUT std_logic
        o_flush : OUT std_logic
        o_freeze : OUT std_logic
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
    signal s_push : std_logic;
    signal s_pop : std_logic;
    signal s_dataIn : std_logic_vector(31 downto 0);
    signal s_interruptType : std_logic:='0';
    -- signal s_stackControl : std_logic_vector(1 downto 0);

    BEGIN
        Process(i_clk)
        BEGIN
            if rising_edge(i_clk) then
                if s_interruptType = '1' then
                    s_interruptType <= '0';
                elsif i_stackControl = "11" then
                    s_interruptType <= '1';
                end if;
            end if;
        end process;

        -- s_stackControl <= (i_stackControl(1) xor s_interruptType) & i_stackControl(0);
        s_address <= i_result when i_stackControl = "00" else s_stachPointer;
        s_push <= '1' when i_stackControl /= "00" and i_writeBack(1) = '0' else '0';
        s_pop <= '1' when i_stackControl /= "00" and i_writeBack(1) = '1' else '0';

        -- dataIn is the data to be written to memory. PC when stackControl = 01 or 11, flag register when stackControl = 11 and s_interruptType = 1, rs2Data otherwise
        s_dataIn <= i_pc when (i_stackControl = "11" and s_interruptType /= '1') or i_stackControl = "01" else
                    i_flag when (i_stackControl = "11" and s_interruptType = '1')
                    else i_rs2Data;


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
        o_writeBack <= i_writeBack when i_stackControl = '10' else "00";
        o_result <= i_result;
        o_rdstAddr <= i_rdstAddr;
        o_rs2Addr <= i_rs2Addr;
        o_rs2Data <= i_rs2Data;
        o_pc <= i_pc;
        o_return <= i_stackControl(0) & i_writeBack(1) & not s_interruptType;
        o_interruptType <= s_interruptType;
        o_freeze <= '1' when (i_stackControl = "11" and s_interruptType = '0') else '0';
        o_flush <= '1' when (i_stackControl = "11" and s_interruptType = '1') or i_stackControl = "01" else '0';
END Behavior;
