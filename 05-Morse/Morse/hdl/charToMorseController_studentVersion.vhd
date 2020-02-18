ARCHITECTURE studentVersion OF charToMorseController IS

  signal isA, isB, isC, isD, isE, isF, isG, isH,
         isI, isJ, isK, isL, isM, isN, isO, isP,
         isQ, isR, isS, isT, isU, isV, isW, isX,
         isY, isZ,
         is0, is1, is2, is3, is4, is5, is6, is7,
         is8, is9 : std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                   -- conditions for morse units
  isA <= '1' when std_match(unsigned(char), "1-0" & x"1") else '0';
  isB <= '1' when std_match(unsigned(char), "1-0" & x"2") else '0';
  isC <= '1' when std_match(unsigned(char), "1-0" & x"3") else '0';
  isD <= '1' when std_match(unsigned(char), "1-0" & x"4") else '0';
  isE <= '1' when std_match(unsigned(char), "1-0" & x"5") else '0';
  isF <= '1' when std_match(unsigned(char), "1-0" & x"6") else '0';
  isG <= '1' when std_match(unsigned(char), "1-0" & x"7") else '0';
  isH <= '1' when std_match(unsigned(char), "1-0" & x"8") else '0';
  isI <= '1' when std_match(unsigned(char), "1-0" & x"9") else '0';
  isJ <= '1' when std_match(unsigned(char), "1-0" & x"A") else '0';
  isK <= '1' when std_match(unsigned(char), "1-0" & x"B") else '0';
  isL <= '1' when std_match(unsigned(char), "1-0" & x"C") else '0';
  isM <= '1' when std_match(unsigned(char), "1-0" & x"D") else '0';
  isN <= '1' when std_match(unsigned(char), "1-0" & x"E") else '0';
  isO <= '1' when std_match(unsigned(char), "1-0" & x"F") else '0';
  isP <= '1' when std_match(unsigned(char), "1-1" & x"0") else '0';
  isQ <= '1' when std_match(unsigned(char), "1-1" & x"1") else '0';
  isR <= '1' when std_match(unsigned(char), "1-1" & x"2") else '0';
  isS <= '1' when std_match(unsigned(char), "1-1" & x"3") else '0';
  isT <= '1' when std_match(unsigned(char), "1-1" & x"4") else '0';
  isU <= '1' when std_match(unsigned(char), "1-1" & x"5") else '0';
  isV <= '1' when std_match(unsigned(char), "1-1" & x"6") else '0';
  isW <= '1' when std_match(unsigned(char), "1-1" & x"7") else '0';
  isX <= '1' when std_match(unsigned(char), "1-1" & x"8") else '0';
  isY <= '1' when std_match(unsigned(char), "1-1" & x"9") else '0';
  isZ <= '1' when std_match(unsigned(char), "1-1" & x"A") else '0';
  is0 <= '1' when std_match(unsigned(char), "011" & x"0") else '0';
  is1 <= '1' when std_match(unsigned(char), "011" & x"1") else '0';
  is2 <= '1' when std_match(unsigned(char), "011" & x"2") else '0';
  is3 <= '1' when std_match(unsigned(char), "011" & x"3") else '0';
  is4 <= '1' when std_match(unsigned(char), "011" & x"4") else '0';
  is5 <= '1' when std_match(unsigned(char), "011" & x"5") else '0';
  is6 <= '1' when std_match(unsigned(char), "011" & x"6") else '0';
  is7 <= '1' when std_match(unsigned(char), "011" & x"7") else '0';
  is8 <= '1' when std_match(unsigned(char), "011" & x"8") else '0';
  is9 <= '1' when std_match(unsigned(char), "011" & x"9") else '0';

  morseOut <= '0';
  startCounter <= '0';
  unitNb <= (others => '-');

END ARCHITECTURE studentVersion;
