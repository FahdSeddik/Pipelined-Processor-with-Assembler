LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY DataMemory IS
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
END ENTITY DataMemory;

ARCHITECTURE mem OF DataMemory IS
    CONSTANT MEM_SIZE : INTEGER := 4095; -- 4k x 17-bit RAM
    -- 4k x 17-bit RAM 
    -- 16-bit data bits and 1 bit to indicate if address is protected
    TYPE ram_type IS ARRAY(0 TO MEM_SIZE) OF std_logic_vector(16 DOWNTO 0);
    SIGNAL ram : ram_type ;
    
    BEGIN
        PROCESS(i_clk) IS
            BEGIN
                IF falling_edge(i_clk) THEN  
                    IF i_memWrite = '1' THEN
                        -- check if address is out of range
                        IF to_integer(unsigned(i_address)) > MEM_SIZE THEN
                            o_exception <= '1';

                        -- check if address is protected
                        ELSIF ram(to_integer(unsigned(i_address)))(16) = '1' THEN
                            o_exception <= '1';

                        ELSE
                            -- little endian
                            ram(to_integer(unsigned(i_address))) <= '0' & i_dataIn(15 DOWNTO 0);
                            ram(to_integer(unsigned(i_address)+1)) <= '0' & i_dataIn(31 DOWNTO 16);
                        END IF;
                    ELSIF i_memRead = '1' THEN
                        IF to_integer(unsigned(i_address)) > MEM_SIZE THEN
                            o_exception <= '1';
                        ELSE
                            -- little endian
                            o_dataOut(15 DOWNTO 0) <= ram(to_integer(unsigned(i_address)))(15 DOWNTO 0);
                            o_dataOut(31 DOWNTO 16) <= ram(to_integer(unsigned(i_address))+1)(15 DOWNTO 0);
                        END IF;
                    ELSIF i_protect = '1' THEN
                        ram(to_integer(unsigned(i_address))) <= '1' & i_dataIn(15 DOWNTO 0);
                        ram(to_integer(unsigned(i_address))+1) <= '1' & i_dataIn(31 DOWNTO 16);
                    ELSIF i_free = '1' THEN
                        ram(to_integer(unsigned(i_address))) <= '0' & i_dataIn(15 DOWNTO 0);
                        ram(to_integer(unsigned(i_address))+1) <= '0' & i_dataIn(31 DOWNTO 16);
                    END IF;
                END IF;
        END PROCESS;
END mem;