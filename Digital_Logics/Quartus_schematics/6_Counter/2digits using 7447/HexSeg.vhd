LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Hex_To_7Seg_Decoder IS
    PORT(
        Data_In  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4비트 16진수 입력 (0-F)
        Dot      : IN  STD_LOGIC;                   -- 소수점 (DP) 입력
        -- 8비트 출력: Seg_Out(7) = DP, Seg_Out(6 DOWNTO 0) = a, b, c, d, e, f, g
        Seg_Out  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END Hex_To_7Seg_Decoder;

ARCHITECTURE Behavioral OF Hex_To_7Seg_Decoder IS
    SIGNAL Seg_Temp : STD_LOGIC_VECTOR(6 DOWNTO 0); -- 임시 7-segment 출력 (a~g)
BEGIN
    -- 1. 4비트 입력에 따른 7-Segment 로직 (a~g)
    WITH Data_In SELECT
        Seg_Temp <= 
            "1111110" WHEN "0000", -- 0
            "0110000" WHEN "0001", -- 1
            "1101101" WHEN "0010", -- 2
            "1111001" WHEN "0011", -- 3
            "0110011" WHEN "0100", -- 4
            "1011011" WHEN "0101", -- 5
            "1011111" WHEN "0110", -- 6
            "1110000" WHEN "0111", -- 7
            "1111111" WHEN "1000", -- 8
            "1111011" WHEN "1001", -- 9
            "1110111" WHEN "1010", -- A
            "0011111" WHEN "1011", -- b (소문자)
            "1001110" WHEN "1100", -- C (대문자)
            "0111101" WHEN "1101", -- d (소문자)
            "1001111" WHEN "1110", -- E
            "1000111" WHEN "1111", -- F
            "0000000" WHEN OTHERS; -- 정의되지 않은 입력 시 모두 꺼짐

    -- 2. 최종 8비트 출력 할당
    -- Seg_Out(7)에 Dot 입력 할당, Seg_Out(6 DOWNTO 0)에 세그먼트 로직 할당
    Seg_Out(7)      <= Dot;
    Seg_Out(6 DOWNTO 0) <= Seg_Temp;
    
END Behavioral;