use std.textio.all;

ARCHITECTURE behav OF flash_28F128J3A IS
                                                                     -- controls
  signal chipSelect : std_ulogic;
  signal writePulse : std_ulogic;
  signal writePulseDelayed : std_ulogic;
  signal memoryCommand : unsigned(7 downto 0);
  signal wordProgramBusy : std_ulogic := '0';
  signal blockEraseBusy : std_ulogic := '0';
  signal busy : std_ulogic;
  signal readPulseCs : std_ulogic := '0';
  signal readPulseOe : std_ulogic := '0';
  signal readPulse : std_ulogic;

  signal memoryAddressDebug : unsigned(A'range);

  type state_type is (
    READ_ARRAY,
    READ_ID_CODES,
    READ_QUERY,
    READ_STATUS,
    WRITE_BUFFER,
    WORD_PROGRAM_1,
    WORD_PROGRAM_2,
    BLOCK_ERASE_1,
    BLOCK_ERASE_2,
    CONFIG,
    PROG_LOCK_BITS,
    PROG_PROT,
                        BOTCH_LOCK,--
                        BOTCH_LOCK_ERS_SUSP,--
                        LOCK_DONE,
                        PROG_LOCK_BITS_ERS_SUSP,--
                        LOCK_DONE_ERS_SUSP,
                        PROT_PROG_BUSY,--
                        PROT_PROG_DONE,--
                        WORD_PROGRAM_1_ERS_SUSP,--
                        PROG_BUSY,--
                        PROG_BUSY_ERS_SUSP,--
                        READ_STATUS_PROG_SUSP,--
                        READ_ARRAY_PROG_SUSP,--
                        READ_CONFIG_PROG_SUSP,--
                        READ_QUERY_PROG_SUSP,--
                        PROGRAM_DONE,--
                        PROGRAM_DONE_ERS_SUSP,--
                        BOTCH_ERS,--
                        ERASE_BUSY,--
                        READ_STATUS_ERS_SUSP,--
                        READ_ARRAY_ERS_SUSP,--
                        READ_CONFIG_ERS_SUSP,--
                        READ_QUERY_ERS_SUSP,--
                        ERASE_DONE--
  );

  signal currentState : state_type;
  signal nextState    : state_type;
                                                                      -- storage
  constant blockLength : positive:= 16#10000#; -- 64 Kword blocks
  constant memoryLength: positive := 2**(A'length-1);
--  constant memoryLength : positive := 2*blockLength;
  subtype memoryWord is std_ulogic_vector(DQ'range);
  type memoryArray is array(0 to memoryLength-1) of memoryWord;
  signal memoryDataWord : memoryWord;

BEGIN

  --############################################################################
  -- Controls
  ------------------------------------------------------------------------------

  chipSelect <= ( (not CE(2)) and (not CE(1)) and (not CE(0)) ) or
                ( CE(2) and ( (not CE(1)) or (not CE(0)) ) );
  writePulse <= chipSelect and not(WE_n);
  writePulseDelayed <= writePulse after 1 ns;

  memoryCommand <= unsigned(DQ(memoryCommand'range));

  process(chipSelect)
  begin
    if rising_edge(chipSelect) then
      readPulseCs <= '1' after T_R3;
    elsif falling_edge(chipSelect) then
      readPulseCs <= '0' after T_R8;
    end if;
  end process;

  process(OE_n)
  begin
    if falling_edge(OE_n) then
      readPulseOe <= '1' after T_R7;
    elsif rising_edge(OE_n) then
      readPulseOe <= '0' after T_R9;
    end if;
  end process;

  readPulse <= readPulseCs and readPulseOe;

  ------------------------------------------------------------------------------
  -- Programming delays
  ------------------------------------------------------------------------------

  wordProgramBusy <= '1', '0' after T_W16_program when currentState = WORD_PROGRAM_2;
  blockEraseBusy <= '1', '0' after T_W16_erase when currentState = BLOCK_ERASE_2;
  busy <= wordProgramBusy or blockEraseBusy;


  ------------------------------------------------------------------------------
  -- FSM: find next state
  ------------------------------------------------------------------------------
                                                                -- Table 4 p. 12
  process(writePulse, busy)
  begin
    case currentState is
      when READ_ARRAY | READ_ID_CODES | READ_QUERY | READ_STATUS =>
        case to_integer(memoryCommand) is
          when 16#FF# => nextState <= READ_ARRAY;
          when 16#90# => nextState <= READ_ID_CODES;
          when 16#98# => nextState <= READ_QUERY;
          when 16#70# => nextState <= READ_STATUS;
          when 16#E8# => nextState <= WRITE_BUFFER;
          when 16#10# | 16#40# => nextState <= WORD_PROGRAM_1;
          when 16#20# => nextState <= BLOCK_ERASE_1;
          when 16#B8# => nextState <= CONFIG;
          when 16#60# => nextState <= PROG_LOCK_BITS;
          when 16#C0# => nextState <= PROG_PROT;
          when others => nextState <= READ_ARRAY;
        end case;

      when WORD_PROGRAM_1 =>
        nextState <= WORD_PROGRAM_2;

      when WORD_PROGRAM_2 =>
        nextState <= READ_ARRAY;

      when BLOCK_ERASE_1 =>
        if to_integer(memoryCommand) = 16#D0# then
          nextState <= BLOCK_ERASE_2;
        else
          nextState <= READ_ARRAY;
        end if;

      when BLOCK_ERASE_2 =>
        nextState <= READ_ARRAY;

--         WHEN PROG_LOCK_BITS  =>
--            IF rising_edge(WENeg) THEN
--            -- SECOND CYCLE CHECK
--                IF data=16#D0# OR data=16#01# OR data=16#2F# THEN
--                    nextState<=READ_ARRAY;
--                ELSE
--                    nextState <= BOTCH_LOCK;
--                END IF;
--            END IF;
--
--        WHEN PROG_LOCK_BITS_ERS_SUSP   =>
--            IF rising_edge(WENeg) THEN
--                IF data=16#D0# OR data=16#01# OR data=16#2F# THEN
--                    nextState<=READ_ARRAY_ERS_SUSP;
--                ELSE
--                    nextState <= BOTCH_LOCK_ERS_SUSP;
--                END IF;
--            END IF;
--
--
--         WHEN LOCK_DONE                  =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# => nextState <= WORD_PROGRAM_1;
--                    WHEN 16#20# => nextState <= BLOCK_ERASE_1;
--                    WHEN 16#70# => nextState <= READ_STATUS;
--                    WHEN 16#90# => nextState <= READ_CONFIG;
--                    WHEN 16#98# => nextState <= READ_QUERY;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS;
--                    WHEN 16#C0# =>  nextState <= PROG_PROT;
--                    WHEN OTHERS => nextState <= READ_ARRAY;
--                END CASE;
--            END IF;
--
--         WHEN LOCK_DONE_ERS_SUSP                  =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# => nextState <= WORD_PROGRAM_1_ERS_SUSP;
--                    WHEN 16#70# => nextState <= READ_STATUS_ERS_SUSP;
--                    WHEN 16#90# => nextState <= READ_CONFIG_ERS_SUSP;
--                    WHEN 16#98# => nextState <= READ_QUERY_ERS_SUSP;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS_ERS_SUSP;
--                    WHEN 16#D0# => nextState <= ERASE_BUSY;
--                    WHEN OTHERS => nextState <= READ_ARRAY_ERS_SUSP;
--                END CASE;
--            END IF;
--
--         WHEN BOTCH_LOCK                  =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# => nextState <= WORD_PROGRAM_1;
--                    WHEN 16#20# => nextState <= BLOCK_ERASE_1;
--                    WHEN 16#70# => nextState <= READ_STATUS;
--                    WHEN 16#90# => nextState <= READ_CONFIG;
--                    WHEN 16#98# => nextState <= READ_QUERY;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS;
--                    WHEN 16#C0# =>  nextState <= PROG_PROT;
--                    WHEN OTHERS => nextState <= READ_ARRAY;
--                END CASE;
--            END IF;
--
--         WHEN BOTCH_LOCK_ERS_SUSP                  =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# =>
--                        nextState <= WORD_PROGRAM_1_ERS_SUSP;
--                    WHEN 16#70# => nextState <= READ_STATUS_ERS_SUSP;
--                    WHEN 16#90# => nextState <= READ_CONFIG_ERS_SUSP;
--                    WHEN 16#98# => nextState <= READ_QUERY_ERS_SUSP;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS_ERS_SUSP;
--                    WHEN OTHERS => nextState <= READ_ARRAY_ERS_SUSP;
--                END CASE;
--            END IF;
--
--
--         WHEN BOTCH_ERS           =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# =>
--                        nextState <= WORD_PROGRAM_1;
--                    WHEN 16#20# => nextState <=BLOCK_ERASE_1;
--                    WHEN 16#70# => nextState <= READ_STATUS;
--                    WHEN 16#90# => nextState <= READ_CONFIG;
--                    WHEN 16#98# => nextState <= READ_QUERY;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS;
--                    WHEN 16#C0# => nextState <= PROG_PROT;
--                    WHEN OTHERS => nextState <= READ_ARRAY;
--                END CASE;
--            END IF;
--
--
--        WHEN PROG_PROT             =>
--            IF rising_edge(WENeg) THEN
--                nextState <= PROT_PROG_BUSY;
--            END IF;
--
--        WHEN PROT_PROG_BUSY              =>
--            IF S_Reg(7)='1' THEN
--                nextState <= PROT_PROG_DONE;
--            ELSE
--                nextState <= PROT_PROG_BUSY;
--            END IF;
--
--        WHEN PROT_PROG_DONE              =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# => nextState <= WORD_PROGRAM_1;
--                    WHEN 16#20# => nextState <= BLOCK_ERASE_1;
--                    WHEN 16#70# => nextState <= READ_STATUS;
--                    WHEN 16#90# => nextState <= READ_CONFIG;
--                    WHEN 16#98# => nextState <= READ_QUERY;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS;
--                    WHEN 16#C0# =>  nextState <= PROG_PROT;
--                    WHEN OTHERS => nextState <= READ_ARRAY;
--                END CASE;
--            END IF;
--
--         WHEN WORD_PROGRAM_1                      =>
--            IF rising_edge(WENeg) THEN
--                nextState <= PROG_BUSY;
--            END IF;
--
--         WHEN WORD_PROGRAM_1_ERS_SUSP             =>
--            IF rising_edge(WENeg) THEN
--                nextState <= PROG_BUSY_ERS_SUSP;
--            END IF;
--
--         WHEN PROG_BUSY                    =>
--            IF WDone THEN
--                nextState<=PROGRAM_DONE;
--            ELSIF rising_edge(WENeg) THEN
--                IF data= 16#B0# THEN
--                    nextState <= READ_STATUS_PROG_SUSP;
--                ELSE
--                    nextState <= PROG_BUSY;
--                END IF;
--            END IF;
--
--         WHEN PROG_BUSY_ERS_SUSP           =>
--            IF WDone THEN
--                nextState<=PROGRAM_DONE_ERS_SUSP;
--            ELSIF rising_edge(WENeg) THEN
--                nextState <= PROG_BUSY_ERS_SUSP;
--            END IF;
--
--         WHEN  READ_STATUS_PROG_SUSP | READ_ARRAY_PROG_SUSP |
--               READ_CONFIG_PROG_SUSP | READ_QUERY_PROG_SUSP  =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    --WHEN 16#D0# => nextState <= READ_ARRAY_PROG_SUSP;
--                    WHEN 16#D0# => nextState <= PROG_BUSY;
--                    WHEN 16#B0# | 16#70# => nextState <= READ_STATUS_PROG_SUSP;
--                    WHEN 16#90# => nextState <= READ_CONFIG_PROG_SUSP;
--                    WHEN 16#98# => nextState <= READ_QUERY_PROG_SUSP;
--                    WHEN OTHERS => nextState <= READ_ARRAY_PROG_SUSP;
--                END CASE;
--            END IF;
--
--         WHEN PROGRAM_DONE                    =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# => nextState <= WORD_PROGRAM_1;
--                    WHEN 16#20# => nextState <= BLOCK_ERASE_1;
--                    WHEN 16#70# => nextState <= READ_STATUS;
--                    WHEN 16#90# => nextState <= READ_CONFIG;
--                    WHEN 16#98# => nextState <= READ_QUERY;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS;
--                    WHEN 16#C0# => nextState <= PROG_PROT;
--                    WHEN OTHERS => nextState <= READ_ARRAY;
--                END CASE;
--            END IF;
--
--         WHEN PROGRAM_DONE_ERS_SUSP          =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# => nextState <= WORD_PROGRAM_1_ERS_SUSP;
--                    WHEN 16#B0# | 16#70# => nextState <= READ_STATUS_ERS_SUSP;
--                    WHEN 16#D0# => nextState <= ERASE_BUSY;
--                    WHEN 16#90# => nextState <= READ_CONFIG_ERS_SUSP;
--                    WHEN 16#98# => nextState <= READ_QUERY_ERS_SUSP;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS_ERS_SUSP;
--                    WHEN OTHERS => nextState <= READ_ARRAY_ERS_SUSP;
--                END CASE;
--            END IF;
--
--
--         WHEN ERASE_BUSY                      =>
--            IF rising_edge(WENeg) AND data= 16#B0# THEN
--                    nextState <= READ_STATUS_ERS_SUSP;
--            ELSIF EDone AND ECount=31 THEN
--                nextState<=ERASE_DONE;
--            ELSE
--                nextState <= ERASE_BUSY;
--            END IF;
--
--         WHEN READ_STATUS_ERS_SUSP | READ_ARRAY_ERS_SUSP |
--              READ_CONFIG_ERS_SUSP | READ_QUERY_ERS_SUSP   =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# => nextState <=WORD_PROGRAM_1_ERS_SUSP;
--                    WHEN 16#B0# | 16#70# | 16#80# =>
--                                    nextState<= READ_STATUS_ERS_SUSP;
--                    WHEN 16#D0# => nextState <= ERASE_BUSY;
--                    WHEN 16#90# => nextState <= READ_CONFIG_ERS_SUSP;
--                    WHEN 16#98# => nextState <= READ_QUERY_ERS_SUSP;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS_ERS_SUSP;
--                    WHEN OTHERS => nextState <= READ_ARRAY_ERS_SUSP;
--                END CASE;
--            END IF;
--
--         WHEN ERASE_DONE                      =>
--            IF rising_edge(WENeg) THEN
--                CASE data IS
--                    WHEN 16#10# | 16#40# => nextState <= WORD_PROGRAM_1;
--                    WHEN 16#20# => nextState <= BLOCK_ERASE_1;
--                    WHEN 16#70# => nextState <= READ_STATUS;
--                    WHEN 16#90# => nextState <= READ_CONFIG;
--                    WHEN 16#98# => nextState <= READ_QUERY;
--                    WHEN 16#60# => nextState <= PROG_LOCK_BITS;
--                    WHEN 16#C0# => nextState <= PROG_PROT;
--                    WHEN OTHERS => nextState <= READ_ARRAY;
--                END CASE;
--            END IF;

when others => nextState <= READ_ARRAY;

    end case;
  end process;


  ------------------------------------------------------------------------------
  -- FSM: update state
  ------------------------------------------------------------------------------
  process(RP_N, writePulseDelayed, busy)
  begin
    if RP_n = '0' then
      currentState <= READ_ARRAY;
    elsif falling_edge(writePulseDelayed) then
      currentState <= nextState;
    elsif falling_edge(busy) then
      currentState <= nextState;
    end if;
  end process;


  ------------------------------------------------------------------------------
  -- STS
  ------------------------------------------------------------------------------
  process
  begin
    STS <= '1';
    wait on busy;
    if rising_edge(busy) then
      STS <= '0' after T_W13;
      wait until falling_edge(busy);
    end if;
  end process;


  --############################################################################
  -- Storage
  ------------------------------------------------------------------------------
  process(writePulse, A)
    variable memContent : memoryArray; -- much faster than using a signal
    variable loadMemFromFile : boolean := true;
    file memoryFile : text open read_mode is fileSpec;
    variable srecLine : line;
    variable srecChar : character;
    variable srecType : natural;
    variable srecAddrLength : natural;
    variable srecWordAscii : string(8 downto 1);
    variable srecLength : natural;
    variable srecAddress : natural;
    variable memoryAddress : natural;
    variable srecData : natural;

    function readNumber(hexString: string) return natural is
      variable currentCharPos: natural;
      variable intValue: natural;
      variable accValue: natural;
    begin
      accValue := 0;
    	for index in hexString'range loop
    	  currentCharPos := character'pos(hexString(index));
        if currentCharPos <= character'pos('9') then
          intValue := currentCharPos - character'pos('0');
        else
          intValue := currentCharPos - character'pos('A') + 10;
        end if;
        accValue := accValue * 16 + intValue;
    	end loop;
    	return accValue;
    end readNumber;

  begin
    if loadMemFromFile then
                                             -- only happens at simulation start
      while not endfile(memoryFile) loop
        readline(memoryFile, srecLine);
        --report "-> " & srecLine.all;
                                                   -- trim leading whitespaces
        while (not (srecLine'length=0)) and (srecLine(srecLine'left) = ' ') loop
          read(srecLine, srecChar);
        end loop;
                                                            -- get record type
        if srecLine'length > 0 then
          read(srecLine, srecChar);
          if (srecChar = 'S') or (srecChar = 's') then
            read(srecLine, srecChar);
            srecType := character'pos(srecChar) - character'pos('0');
            --report "-> srec type: " & integer'image(srecType);
            srecAddrLength := srecType + 1;
            if (srecType >= 1) and (srecType <= 3) then
                                                          -- get record length
              srecWordAscii := (others => '0');
              read(srecLine, srecWordAscii(2));
              read(srecLine, srecWordAscii(1));
              srecLength := readNumber(srecWordAscii);
                                                    -- get record base address
              srecWordAscii := (others => '0');
            	for index in 2*(srecAddrLength) downto 1 loop
                read(srecLine, srecWordAscii(index));
            	end loop;
              srecAddress := readNumber(srecWordAscii);
              memoryAddress := srecAddress/2;
                                                            -- get record data
            	for index1 in 1 to (srecLength - srecAddrLength - 1) / 2 loop
                srecWordAscii := (others => '0');
              	for index2 in 4 downto 1 loop
                  read(srecLine, srecWordAscii(index2));
              	end loop;
              	srecData := readNumber(srecWordAscii);
                if memoryAddress < memoryLength then
              	  memContent(memoryAddress) := std_ulogic_vector(to_unsigned(srecData, memoryWord'length));
            	  end if;
            	  memoryAddress := memoryAddress + 1;
            	end loop;
            end if;
          end if;
        end if;
      end loop;
      loadMemFromFile := false;
    else
                                                         -- normal functionality
      if falling_edge(writePulse) then
                                                             -- program a word
        if currentState = WORD_PROGRAM_1 then
          memoryAddress := to_integer(A(A'high downto 1));
memoryAddressDebug <= to_unsigned(memoryAddress, memoryAddressDebug'length);
          memContent(memoryAddress) := std_ulogic_vector(DQ);
                                                              -- erase a block
        elsif currentState = BLOCK_ERASE_1 then
          memoryAddress := to_integer(A and not(to_unsigned(blockLength-1, A'length)));
          for index in 0 to blockLength-1 loop
            if memoryAddress < memoryLength then
              memContent(memoryAddress) := (others => '1');
           	  memoryAddress := memoryAddress + 1;
            end if;
          end loop;
        end if;
      end if;
                                                        -- update readout data
      if A'event then
        memoryAddress := to_integer(A(A'high downto 1));
memoryAddressDebug <= to_unsigned(memoryAddress, memoryAddressDebug'length);
        memoryDataWord <= memContent(memoryAddress) after T_R2;
      end if;
    end if;
  end process;

  process(memoryDataWord, readPulse)
  begin
    if readPulse = '1' then
      DQ <= std_logic_vector(memoryDataWord);
    else
      DQ <= (others => 'Z');
    end if;
  end process;



END ARCHITECTURE behav;

