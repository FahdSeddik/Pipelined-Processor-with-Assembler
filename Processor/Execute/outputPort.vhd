library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
entity outputPort is port(
    i_clk,i_rst,i_outputEnable: in std_logic;
    i_result: in std_logic_vector(31 downto 0);
    o_output: out std_logic_vector(31 downto 0) 
);
end entity outputPort;
architecture imp of outputPort is
    signal outp: std_logic_vector(31 downto 0);
begin
    process(i_clk,i_rst)
    begin
        if(i_rst='1') then
            outp<=x"00000000";
        elsif(falling_edge(i_clk)) then
            if(i_outputEnable='1') then
                outp<=i_result;
            end if;
        end if;
    end process;
    o_output<=outp;
end imp;
