ARCHITECTURE mapped OF programRom IS

  subtype opCodeType is std_ulogic_vector(5 downto 0);
  constant opLoadC   : opCodeType := "000000";
  constant opLoadR   : opCodeType := "000001";
  constant opInputC  : opCodeType := "000100";
  constant opInputR  : opCodeType := "000101";
  constant opFetchC  : opCodeType := "000110";
  constant opFetchR  : opCodeType := "000111";
  constant opAndC    : opCodeType := "001010";
  constant opAndR    : opCodeType := "001011";
  constant opOrC     : opCodeType := "001100";
  constant opOrR     : opCodeType := "001101";
  constant opXorC    : opCodeType := "001110";
  constant opXorR    : opCodeType := "001111";
  constant opTestC   : opCodeType := "010010";
  constant opTestR   : opCodeType := "010011";
  constant opCompC   : opCodeType := "010100";
  constant opCompR   : opCodeType := "010101";
  constant opAddC    : opCodeType := "011000";
  constant opAddR    : opCodeType := "011001";
  constant opAddCyC  : opCodeType := "011010";
  constant opAddCyR  : opCodeType := "011011";
  constant opSubC    : opCodeType := "011100";
  constant opSubR    : opCodeType := "011101";
  constant opSubCyC  : opCodeType := "011110";
  constant opSubCyR  : opCodeType := "011111";
  constant opShRot   : opCodeType := "100000";
  constant opOutputC : opCodeType := "101100";
  constant opOutputR : opCodeType := "101101";
  constant opStoreC  : opCodeType := "101110";
  constant opStoreR  : opCodeType := "101111";

  subtype shRotCinType is std_ulogic_vector(2 downto 0);
  constant shRotLdC : shRotCinType := "00-";
  constant shRotLdM : shRotCinType := "01-";
  constant shRotLdL : shRotCinType := "10-";
  constant shRotLd0 : shRotCinType := "110";
  constant shRotLd1 : shRotCinType := "111";

  constant registerAddressBitNb : positive := 4;
  constant shRotPadLength : positive
    := dataOut'length - opCodeType'length - registerAddressBitNb
     - 1 - shRotCinType'length;
  subtype shRotDirType is std_ulogic_vector(1+shRotPadLength-1 downto 0);
  constant shRotL : shRotDirType := (0 => '0', others => '-');
  constant shRotR : shRotDirType := (0 => '1', others => '-');

  subtype branchCodeType is std_ulogic_vector(4 downto 0);
  constant brRet  : branchCodeType := "10101";
  constant brCall : branchCodeType := "11000";
  constant brJump : branchCodeType := "11010";
  constant brReti : branchCodeType := "11100";
  constant brEni  : branchCodeType := "11110";

  subtype branchConditionType is std_ulogic_vector(2 downto 0);
  constant brDo : branchConditionType := "000";
  constant brZ  : branchConditionType := "100";
  constant brNZ : branchConditionType := "101";
  constant brC  : branchConditionType := "110";
  constant brNC : branchConditionType := "111";

  subtype memoryWordType is std_ulogic_vector(dataOut'range);
  type memoryArrayType is array (0 to 2**address'length-1) of memoryWordType;

  signal memoryArray : memoryArrayType := (
                                                         --===============================================================
                                                         -- Beamer control
                                                         --===============================================================
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- register definitions
                                                         --   s0, s1: used for INPUT and OUTPUT operations
                                                         --   S2: returns UART data byte
                                                         --   S3: uart protocol checksum
                                                         --   S4: uart protocol packet id
                                                         --   S5: uart protocol command id
                                                         --   S6: uart protocol address
                                                         --   S7: uart protocol data
                                                         --   S8: copy of UART data byte for debug
                                                         -----------------------------------------------------------------
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- GPIO definitions
                                                         -----------------------------------------------------------------
                                                         -----------------------------------------------------------------
                                                         -- UART definitions
                                                         -----------------------------------------------------------------
                                                         --                CONSTANT  uartBaudCount,    023D        ; 66E6 / 115 200 = 573
                                                         --                CONSTANT  uartpollDelay,    0100
                                                         -----------------------------------------------------------------
                                                         -- beamer peripheral definitions
                                                         -----------------------------------------------------------------
                                                         --                CONSTANT  beamerCtlInit,    1001
                                                         --
                                                         --===============================================================
                                                         -- initializations
                                                         --===============================================================
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- initialize GPIO
                                                         -----------------------------------------------------------------
    16#000# => opLoadC   & "0000" & "0000000000000000",  -- LOAD      s0, 0000
    16#001# => opAddC    & "0000" & "0000000000000000",  -- ADD       s0, 0000
    16#002# => opLoadC   & "0001" & "0000000010101010",  -- LOAD      s1, AA
    16#003# => opOutputR & "0001" & "0000------------",  -- OUTPUT    s1, (S0)
    16#004# => opLoadC   & "0000" & "0000000000000000",  -- LOAD      s0, 0000
    16#005# => opAddC    & "0000" & "0000000000000001",  -- ADD       s0, 0001
    16#006# => opLoadC   & "0001" & "0000000000001111",  -- LOAD      s1, 0F
    16#007# => opOutputR & "0001" & "0000------------",  -- OUTPUT    s1, (S0)
                                                         -----------------------------------------------------------------
                                                         -- initialize UART
                                                         -----------------------------------------------------------------
    16#008# => opLoadC   & "0000" & "0000000000010000",  -- LOAD      s0, 0010
    16#009# => opAddC    & "0000" & "0000000000000010",  -- ADD       s0, 0002
    16#00A# => opLoadC   & "0001" & "0000000001000010",  -- LOAD      s1, 0042
    16#00B# => opOutputR & "0001" & "0000------------",  -- OUTPUT    s1, (S0)
                                                         -----------------------------------------------------------------
                                                         -- initialize beamer peripheral
                                                         -----------------------------------------------------------------
    16#00C# => opLoadC   & "0000" & "0000000000100000",  -- LOAD      s0, 0020
    16#00D# => opAddC    & "0000" & "0000000000000000",  -- ADD       s0, 0000
    16#00E# => opLoadC   & "0001" & "0000010000000001",  -- LOAD      s1, 0401
    16#00F# => opOutputR & "0001" & "0000------------",  -- OUTPUT    s1, (S0)
    16#010# => opLoadC   & "0000" & "0000000000100000",  -- LOAD      s0, 0020
    16#011# => opAddC    & "0000" & "0000000000000001",  -- ADD       s0, 0001
    16#012# => opLoadC   & "0001" & "0000000000000100",  -- LOAD      s1, 0004
    16#013# => opOutputR & "0001" & "0000------------",  -- OUTPUT    s1, (S0)
                                                         --
                                                         --===============================================================
                                                         -- Main loop
                                                         --===============================================================
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- Process commands from serial port
                                                         -----------------------------------------------------------------
                                                         -- _main_:
    16#014# => brCall    & brDo   & "--------0000100001",-- CALL      021        ; get command from UART
    16#015# => opCompC   & "0011" & "0000000000000000",  -- COMPARE   s3, 0000   ; check function return
    16#016# => brJump    & brNZ   & "--------0000011111",-- JUMP      NZ, 01F
    16#017# => opCompC   & "0101" & "0000000000000011",  -- COMPARE   s5, 0003   ; check for WRITE_MEM command
    16#018# => brJump    & brNZ   & "--------0000011100",-- JUMP      NZ, 01C
    16#019# => opOutputR & "0111" & "0110------------",  -- OUTPUT    s7, (S6)   ; write word to memory location
    16#01A# => brCall    & brDo   & "--------0001100000",-- CALL      060        ; send write acknowledge
    16#01B# => brJump    & brDo   & "--------0000010100",-- JUMP      014
                                                         -- _commandRead_:
    16#01C# => opInputR  & "0111" & "0110------------",  -- INPUT     s7, (S6)   ; write word in memory location
    16#01D# => brCall    & brDo   & "--------0001101111",-- CALL      06F        ; send back read data
    16#01E# => brJump    & brDo   & "--------0000010100",-- JUMP      014
                                                         -- _commandAbort_:
    16#01F# => brCall    & brDo   & "--------0001010001",-- CALL      051
    16#020# => brJump    & brDo   & "--------0000010100",-- JUMP      014
                                                         --
                                                         --===============================================================
                                                         -- Subroutines
                                                         --===============================================================
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- Get command from serial port
                                                         -----------------------------------------------------------------
                                                         -- _uartGetCmd_:
    16#021# => brCall    & brDo   & "--------0010000110",-- CALL      086        ; get command header
    16#022# => opCompC   & "0010" & "0000000010101010",  -- COMPARE   s2, 00AA
    16#023# => brJump    & brNZ   & "--------0000100001",-- JUMP      NZ, 021    ; loop until byte is AAh
    16#024# => opLoadR   & "0011" & "0010------------",  -- LOAD      s3, s2     ; prepare checksum
    16#025# => brCall    & brDo   & "--------0010000110",-- CALL      086        ; get packet id
    16#026# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#027# => opLoadR   & "0100" & "0010------------",  -- LOAD      s4, s2     ; store id for reply
    16#028# => brCall    & brDo   & "--------0010000110",-- CALL      086        ; get command
    16#029# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#02A# => opCompC   & "0010" & "0000000000000011",  -- COMPARE   s2, 0003   ; check for WRITE_MEM command
    16#02B# => brJump    & brZ    & "--------0000101111",-- JUMP      Z, 02F
    16#02C# => opCompC   & "0010" & "0000000000000100",  -- COMPARE   s2, 0004   ; check for READ_MEM command
    16#02D# => brJump    & brZ    & "--------0000101111",-- JUMP      Z, 02F
    16#02E# => brJump    & brDo   & "--------0001001111",-- JUMP      04F        ; no match
                                                         -- _commandOk_:
    16#02F# => opLoadR   & "0101" & "0010------------",  -- LOAD      s5, s2     ; store command for action
    16#030# => brCall    & brDo   & "--------0010000110",-- CALL      086        ; get data length
    16#031# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#032# => opCompC   & "0101" & "0000000000000011",  -- COMPARE   s5, 0003   ; check for WRITE_MEM command
    16#033# => brJump    & brZ    & "--------0000110111",-- JUMP      Z, 037     ; go to test write command length
    16#034# => opCompC   & "0010" & "0000000000000010",  -- COMPARE   s2, 0002   ; verify READ_MEM length
    16#035# => brJump    & brNZ   & "--------0001001111",-- JUMP      NZ, 04F
    16#036# => brJump    & brDo   & "--------0000111001",-- JUMP      039
                                                         -- _testWrLength_:
    16#037# => opCompC   & "0010" & "0000000000000100",  -- COMPARE   s2, 0004   ; verify WRITE_MEM length
    16#038# => brJump    & brNZ   & "--------0001001111",-- JUMP      NZ, 04F
                                                         -- _getAddress_:
    16#039# => brCall    & brDo   & "--------0010000110",-- CALL      086        ; get address low
    16#03A# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#03B# => opLoadR   & "0110" & "0010------------",  -- LOAD      s6, s2     ; store address low
    16#03C# => brCall    & brDo   & "--------0010000110",-- CALL      086        ; get address high
    16#03D# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#03E# => brCall    & brDo   & "--------0010100000",-- CALL      0A0
    16#03F# => opAddR    & "0110" & "0010------------",  -- ADD       s6, s2     ; build address from low and high
    16#040# => opCompC   & "0101" & "0000000000000100",  -- COMPARE   s5, 0004   ; check for READ_MEM command
    16#041# => brJump    & brZ    & "--------0001001001",-- JUMP      Z, 049     ; skip reading data word
    16#042# => brCall    & brDo   & "--------0010000110",-- CALL      086        ; get data low
    16#043# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#044# => opLoadR   & "0111" & "0010------------",  -- LOAD      s7, s2     ; store data low
    16#045# => brCall    & brDo   & "--------0010000110",-- CALL      086        ; get data high
    16#046# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#047# => brCall    & brDo   & "--------0010100000",-- CALL      0A0
    16#048# => opAddR    & "0111" & "0010------------",  -- ADD       s7, s2     ; build data from low and high
                                                         -- _getChecksum_:
    16#049# => brCall    & brDo   & "--------0010000110",-- CALL      086        ; get checksum
    16#04A# => opAndC    & "0011" & "0000000011111111",  -- AND       s3, 00FF   ; limit calculated checksum to 8 bit
    16#04B# => opCompR   & "0011" & "0010------------",  -- COMPARE   s3, s2     ; test checksum
    16#04C# => brJump    & brNZ   & "--------0001001111",-- JUMP      NZ, 04F
    16#04D# => opLoadC   & "0011" & "0000000000000000",  -- LOAD      s3, 0000   ; return OK
    16#04E# => brRet     & brDo   & "------------------",-- RETURN
                                                         -- _commandKo_:
    16#04F# => opLoadC   & "0011" & "0000000000000001",  -- LOAD      s3, 0001   ; return KO
    16#050# => brRet     & brDo   & "------------------",-- RETURN
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- send NACK reply
                                                         -----------------------------------------------------------------
                                                         -- _sendNAck_:
    16#051# => opLoadC   & "0010" & "0000000010101010",  -- LOAD      s2, 00AA   ; send header
    16#052# => opLoadR   & "0011" & "0010------------",  -- LOAD      s3, s2     ; prepare checksum
    16#053# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#054# => opLoadR   & "0010" & "0100------------",  -- LOAD      s2, s4     ; packet id
    16#055# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#056# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#057# => opLoadC   & "0010" & "0000000000000000",  -- LOAD      s2, 0000   ; negative Acknowledge
    16#058# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#059# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#05A# => opLoadC   & "0010" & "0000000000000000",  -- LOAD      s2, 0000   ; packet length: no data
    16#05B# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#05C# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#05D# => opLoadR   & "0010" & "0011------------",  -- LOAD      s2, s3     ; checksum
    16#05E# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#05F# => brRet     & brDo   & "------------------",-- RETURN
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- send WRITE_MEM reply
                                                         -----------------------------------------------------------------
                                                         -- _sendWriteOk_:
    16#060# => opLoadC   & "0010" & "0000000010101010",  -- LOAD      s2, 00AA   ; send header
    16#061# => opLoadR   & "0011" & "0010------------",  -- LOAD      s3, s2     ; prepare checksum
    16#062# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#063# => opLoadR   & "0010" & "0100------------",  -- LOAD      s2, s4     ; packet id
    16#064# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#065# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#066# => opLoadR   & "0010" & "0101------------",  -- LOAD      s2, s5     ; received command
    16#067# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#068# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#069# => opLoadC   & "0010" & "0000000000000000",  -- LOAD      s2, 0000   ; packet length: no data
    16#06A# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#06B# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#06C# => opLoadR   & "0010" & "0011------------",  -- LOAD      s2, s3     ; checksum
    16#06D# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#06E# => brRet     & brDo   & "------------------",-- RETURN
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- send READ_MEM reply
                                                         -----------------------------------------------------------------
                                                         -- _sendReadData_:
    16#06F# => opLoadC   & "0010" & "0000000010101010",  -- LOAD      s2, 00AA   ; send header
    16#070# => opLoadR   & "0011" & "0010------------",  -- LOAD      s3, s2     ; prepare checksum
    16#071# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#072# => opLoadR   & "0010" & "0100------------",  -- LOAD      s2, s4     ; packet id
    16#073# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#074# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#075# => opLoadR   & "0010" & "0101------------",  -- LOAD      s2, s5     ; received command
    16#076# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#077# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#078# => opLoadC   & "0010" & "0000000000000010",  -- LOAD      s2, 0002   ; packet length: 2 bytes
    16#079# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#07A# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#07B# => opLoadR   & "0010" & "0111------------",  -- LOAD      s2, s7     ; data low
    16#07C# => opAndC    & "0010" & "0000000011111111",  -- AND       s2, 00FF   ; keep low byte only
    16#07D# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#07E# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#07F# => opLoadR   & "0010" & "0111------------",  -- LOAD      s2, s7     ; data high
    16#080# => brCall    & brDo   & "--------0010100101",-- CALL      0A5        ; shift MSBs down to LSBs
    16#081# => opAddR    & "0011" & "0010------------",  -- ADD       s3, s2     ; calculate checksum
    16#082# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#083# => opLoadR   & "0010" & "0011------------",  -- LOAD      s2, s3     ; checksum
    16#084# => brCall    & brDo   & "--------0010010011",-- CALL      093
    16#085# => brRet     & brDo   & "------------------",-- RETURN
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- Get byte from serial port
                                                         -----------------------------------------------------------------
                                                         -- _uartGetByte_:
    16#086# => opLoadC   & "0000" & "0000000000010000",  -- LOAD      s0, 0010   ; read UART satus register
    16#087# => opAddC    & "0000" & "0000000000000001",  -- ADD       s0, 01
                                                         --load s8, 0100
                                                         -- _checkStat_:
    16#088# => opLoadC   & "0010" & "0000000001000000",  -- LOAD      s2, 0040   ; add delay between bus reads
                                                         -- _delay0_:
    16#089# => opSubC    & "0010" & "0000000000000001",  -- SUB       s2, 0001
    16#08A# => brJump    & brNZ   & "--------0010001001",-- JUMP      NZ, 089
                                                         --sub s8, 0001
                                                         --jump nz, continue
                                                         --load s2, 0035
                                                         --call uartSendByte
                                                         --load s8, 0100
                                                         -- _continue_:
    16#08B# => opInputR  & "0001" & "0000------------",  -- INPUT     s1, (S0)
    16#08C# => opInputR  & "0001" & "0000------------",  -- INPUT     s1, (S0)
    16#08D# => opTestC   & "0001" & "0000000000000001",  -- TEST      s1, 0001   ; check "data ready" bit
    16#08E# => brJump    & brZ    & "--------0010001000",-- JUMP      Z, 088     ; loop until bit is '1'
    16#08F# => opLoadC   & "0000" & "0000000000010000",  -- LOAD      s0, 0010   ; read UART data register
    16#090# => opInputR  & "0010" & "0000------------",  -- INPUT     s2, (S0)
    16#091# => opInputR  & "0010" & "0000------------",  -- INPUT     s2, (S0)
                                                         --LOAD s8, s2
    16#092# => brRet     & brDo   & "------------------",-- RETURN
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- Send byte to serial port
                                                         -----------------------------------------------------------------
                                                         -- _uartSendByte_:
    16#093# => opLoadC   & "0000" & "0000000000010000",  -- LOAD      s0, 0010   ; read UART satus register
    16#094# => opAddC    & "0000" & "0000000000000001",  -- ADD       s0, 0001
                                                         -- _readStatus_:
    16#095# => opInputR  & "0001" & "0000------------",  -- INPUT     s1, (S0)
    16#096# => opInputR  & "0001" & "0000------------",  -- INPUT     s1, (S0)
    16#097# => opTestC   & "0001" & "0000000000000010",  -- TEST      s1, 0002   ; check "sending data" bit
    16#098# => brJump    & brZ    & "--------0010011101",-- JUMP      Z, 09D     ; loop until bit is '1'
    16#099# => opLoadC   & "0001" & "0000000001000000",  -- LOAD      s1, 0040   ; add delay between bus reads
                                                         -- _delay1_:
    16#09A# => opSubC    & "0001" & "0000000000000001",  -- SUB       s1, 0001
    16#09B# => brJump    & brNZ   & "--------0010011010",-- JUMP      NZ, 09A
    16#09C# => brJump    & brDo   & "--------0010010101",-- JUMP      095
                                                         -- _sendByte_:
    16#09D# => opLoadC   & "0000" & "0000000000010000",  -- LOAD      s0, 0010   ; write UART data register
    16#09E# => opOutputR & "0010" & "0000------------",  -- OUTPUT    s2, (S0)
    16#09F# => brRet     & brDo   & "------------------",-- RETURN
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- shift s2 8 bits to the left
                                                         -----------------------------------------------------------------
                                                         -- _shiftS2L8_:
    16#0A0# => opLoadC   & "0000" & "0000000000001000",  -- LOAD      s0, 8      ; loop count
                                                         -- _shiftLeftLoop_:
    16#0A1# => opShRot   & "0010" & shRotL & shRotLd0,   -- SL0       s2
    16#0A2# => opSubC    & "0000" & "0000000000000001",  -- SUB       s0, 0001
    16#0A3# => brJump    & brNZ   & "--------0010100001",-- JUMP      NZ, 0A1
    16#0A4# => brRet     & brDo   & "------------------",-- RETURN
                                                         --
                                                         -----------------------------------------------------------------
                                                         -- shift s2 8 bits to the right
                                                         -----------------------------------------------------------------
                                                         -- _shiftS2R8_:
    16#0A5# => opLoadC   & "0000" & "0000000000001000",  -- LOAD      s0, 8      ; loop count
                                                         -- _shiftRightLoop_:
    16#0A6# => opShRot   & "0010" & shRotR & shRotLd0,   -- SR0       s2
    16#0A7# => opSubC    & "0000" & "0000000000000001",  -- SUB       s0, 0001
    16#0A8# => brJump    & brNZ   & "--------0010100110",-- JUMP      NZ, 0A6
    16#0A9# => brRet     & brDo   & "------------------",-- RETURN
                                                         --
                                                         --===============================================================
                                                         -- End of instruction memory
                                                         --===============================================================
                                                         -- _endOfMemory_:
    16#3FF# => brJump    & brDo   & "--------1111111111",-- JUMP      3FF
    others => (others => '0')
  );

BEGIN

  process (clock)
  begin
    if rising_edge(clock) then
      if en = '1' then
        dataOut <= memoryArray(to_integer(address));
      end if;
    end if;
  end process;

END ARCHITECTURE mapped;
