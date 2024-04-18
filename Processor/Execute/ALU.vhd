--add,sub,not,or,xor,and,a,b,a+1,a-1,-a
--opcodes
--add(1000),sub(1001),a+1(1010),a-1(1011),-a(1100),not(0100),and(0101),or(0110),xor(0111),a(0000),b(0001)
--flags
--zero,neg,carry,overflow
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
entity ALU is port(
    i_a,i_b: in std_logic_vector(31 downto 0);
    i_op: in std_logic_vector(3 downto 0);
    o_result: out std_logic_vector(31 downto 0);
    o_flags: out std_logic_vector(3 downto 0) --[3]overflow,[2]carry,[1]neg,[0]zero
);
end ALU;
architecture imp of ALU is
    signal temp: std_logic_vector(32 downto 0);
    begin 
    temp<= std_logic_vector(unsigned("0"&i_a) + unsigned(i_b)) when i_op="1000" else
    std_logic_vector(unsigned("0"&i_a) - unsigned(i_b)) when i_op="1001" else
    std_logic_vector(unsigned("0"&i_a) + 1) when i_op="1010" else
    std_logic_vector(unsigned("0"&i_a) - 1) when i_op="1011" else
    std_logic_vector(x"00000000"-unsigned("0"&i_a)) when i_op="1100" else
    not ("0"&i_a) when i_op="0100" else
    ("0"&i_a) and ("0"&i_b) when i_op="0101" else
    ("0"&i_a) or ("0"&i_b) when i_op="0110" else
    ("0"&i_a) xor ("0"&i_b) when i_op="0111" else
    "0"&i_a when i_op="0000" else
    "0"&i_b when i_op="0001" else
    (others=>'0');
    o_flags(0)<='1' when temp(31 downto 0)=x"000000000" else '0';
    o_flags(1)<=temp(31);
    o_flags(2)<=temp(32);
    o_flags(3)<=(i_a(31) xor temp(31)) and (i_a(31) xnor i_b(31)) when i_op="1000" else
    (i_a(31) xor temp(31)) and (i_a(31) xor i_b(31)) when i_op="1001" else
    (i_a(31) xor temp(31)) and (i_a(31) xnor '0') when i_op="1010" else
    (i_a(31) xor temp(31)) and (i_a(31) xor '0') when i_op="1011" else
    '0';
    o_result<=temp(31 downto 0);
    end imp;