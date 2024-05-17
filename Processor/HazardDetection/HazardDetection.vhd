LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY HazardDetector IS
    PORT (
        i_aRs1, i_aRs2, i_aRd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        i_aMemRead : IN STD_LOGIC;
        o_Hazard : OUT STD_LOGIC
    );
END HazardDetector;

ARCHITECTURE imp OF HazardDetector IS
BEGIN
    o_Hazard <= '1' WHEN (i_aRs1 = i_aRd OR i_aRs2 = i_aRd) AND i_aMemRead = '1' ELSE
        '0';
END imp; -- imp