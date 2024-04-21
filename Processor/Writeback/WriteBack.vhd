LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY WriteBack IS
    PORT(
        -- input signals
        i_memRead : IN std_logic;
        i_writeBack : IN std_logic_vector(1 downto 0);
        i_readData : IN std_logic_vector(31 downto 0);
        i_result : IN std_logic_vector(31 downto 0);
        i_rdstAddr : IN std_logic_vector(2 downto 0);
        i_rs2Addr : IN std_logic_vector(2 downto 0);
        i_rs2Data : IN std_logic_vector(31 downto 0);
        -- output signals
        o_writeBack : OUT std_logic_vector(1 downto 0);
        o_data : OUT std_logic_vector(31 downto 0);
        o_rdstAddr : OUT std_logic_vector(2 downto 0);
        o_rs2Addr : OUT std_logic_vector(2 downto 0);
        o_rs2Data : OUT std_logic_vector(31 downto 0)  
    );
END WriteBack;

ARCHITECTURE WriteBack OF WriteBack IS
BEGIN
    o_data <= i_result when i_memRead = '0' else i_readData;
    o_writeBack <= i_writeBack;
    o_rdstAddr <= i_rdstAddr;
    o_rs2Addr <= i_rs2Addr;
    o_rs2Data <= i_rs2Data;
END WriteBack;