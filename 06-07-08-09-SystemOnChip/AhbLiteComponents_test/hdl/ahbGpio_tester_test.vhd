LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE test OF ahbGpio_tester IS
                                                              -- reset and clock
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';
  signal reset_int: std_uLogic;
                                                             -- test information
  signal noteTopSeparator : string(1 to 80) := (others => '-');
  signal errorTopSeparator : string(1 to 80) := (others => '#');
  signal bottomSeparator : string(1 to 80) := (others => '.');
  signal indentation : string(1 to 2) := (others => ' ');
  signal noteInformation : string(1 to 9) := (others => ' ');
  signal errorInformation : string(1 to 10) := (others => ' ');
  signal failureInformation : string(1 to 12) := (others => ' ');
  signal testInformation : string(1 to 50) := (others => ' ');
                                                          -- register definition
  constant peripheralBaseAddress: natural := 2**4;
  constant dataRegisterAddress: natural := 0;
  constant outputEnableRegisterAddress: natural := 1;
                                                              -- AMBA bus access
  signal registerAddress: natural;
  signal registerData: integer;
  signal registerWrite: std_uLogic;
  signal registerRead: std_uLogic;
  signal writeFlag, readFlag, readFlag1: std_uLogic;
  signal writeData, readData: integer;
                                                                  -- GPIO access
  signal ioData: integer;
  signal ioMask: integer;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset_int <= '1', '0' after 2*clockPeriod;
  hReset_n <= not(reset_int);

  clock_int <= not clock_int after clockPeriod/2;
  hClk <= transport clock_int after clockPeriod*9.0/10.0;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  testSequence: process
  begin
    registerAddress <= 0;
    registerData <= 0;
    registerWrite <= '0';
    registerRead <= '0';
    ioData <= 0;
    ioMask <= 0;
    wait for 100 ns;

    ----------------------------------------------------------------------------
                                                                  -- simple test
                                                                -- write en mask
    testInformation <= pad("Writing data on the GPIO", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    ioData <= 16#AA#;
    ioMask <= 16#0F#; wait for 0 ns;
    registerAddress <= outputEnableRegisterAddress;
    registerData <= ioMask;
    registerWrite <= '1', '0' after clockPeriod/2;
    wait for 4*clockPeriod;
                                                        -- write output data 55h
    registerAddress <= dataRegisterAddress;
    registerData <= 16#55#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 4*clockPeriod;
    assert io = x"A5"
      report
        errorTopSeparator & cr &
        noteInformation & indentation & "IO data not as expected" & cr &
        noteInformation & bottomSeparator
      severity error;
                                                                    -- read data
    testInformation <= pad("Reading data from the GPIO", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    registerAddress <= dataRegisterAddress;
    registerRead <= '1', '0' after clockPeriod;
    for index in 1 to 4 loop
      wait until rising_edge(clock_int);
    end loop;
    assert readData = 16#A5#
      report
        errorTopSeparator & cr &
        noteInformation & indentation & "read data not as expected" & cr &
        noteInformation & bottomSeparator
      severity error;
    wait for 100 ns;

    ----------------------------------------------------------------------------
                                           -- test with a different base address
                                                                -- write en mask
    testInformation <= pad(
      "Writing data to a different base address", testInformation'length
    );
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    ioData <= 16#AA#;
    ioMask <= 16#F0#; wait for 0 ns;
    registerAddress <= peripheralBaseAddress + outputEnableRegisterAddress;
    registerData <= ioMask;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 4*clockPeriod;
                                                        -- write output data 55h
    registerAddress <= peripheralBaseAddress + dataRegisterAddress;
    registerData <= 16#55#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 4*clockPeriod;
                                                                    -- read data
    registerAddress <= peripheralBaseAddress + dataRegisterAddress;
    registerRead <= '1', '0' after clockPeriod;
    for index in 1 to 4 loop
      wait until rising_edge(clock_int);
    end loop;
    assert readData = 16#5A#
      report
        errorTopSeparator & cr &
        noteInformation & indentation & "read data not as expected" & cr &
        noteInformation & bottomSeparator
      severity error;
    wait for 4*clockPeriod;

    ----------------------------------------------------------------------------
                                                          -- access back to back
                                                                -- write en mask
    testInformation <= pad("Accessing at full speed", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    wait until rising_edge(clock_int);
    ioData <= 16#AA#;
    ioMask <= 16#0F#; wait for 0 ns;
    registerAddress <= outputEnableRegisterAddress;
    registerData <= ioMask;
    registerWrite <= '1' after clockPeriod/4, '0' after clockPeriod/2;
                                                        -- write output data 55h
    wait until rising_edge(clock_int);
    registerAddress <= dataRegisterAddress;
    registerData <= 16#55#;
    registerWrite <= '1' after clockPeriod/4, '0' after clockPeriod/2;
                                                                    -- read data
    wait until rising_edge(clock_int);
    registerAddress <= dataRegisterAddress;
    registerRead <= '1' after clockPeriod/4, '0' after clockPeriod/2;
    for index in 1 to 4 loop
      wait until rising_edge(clock_int);
    end loop;
    assert readData = 16#A5#
      report
        errorTopSeparator & cr &
        noteInformation & indentation & "read data not as expected" & cr &
        noteInformation & bottomSeparator
      severity error;
    wait for 4*clockPeriod;
                                                            -- end of simulation
    wait for 100 ns;
    testInformation <= pad("End of tests", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        failureInformation & indentation & testInformation & cr &
        failureInformation & bottomSeparator
      severity failure;
    wait;
  end process testSequence;

  ------------------------------------------------------------------------------
                                                              -- AMBA bus access
                                                -- phase 1: address and controls
  busAccess1: process
    variable writeAccess: boolean := false;
  begin
    wait on reset_int, registerWrite, registerRead;
    if falling_edge(reset_int) then
      hAddr <= (others => '-');
      hTrans <= transIdle;
      hSel <= '0';
      writeFlag <= '0';
    end if;
    if rising_edge(registerWrite) or rising_edge(registerRead) then
      writeAccess := false;
      if rising_edge(registerWrite) then
        writeAccess := true;
      end if;
      wait until rising_edge(clock_int);
      hAddr <= to_unsigned(registerAddress, hAddr'length),
        (others => '-') after clockPeriod + 1 ns;
      hTrans <= transNonSeq, transIdle after clockPeriod + 1 ns;
      hSel <= '1', '0' after clockPeriod + 1 ns;
      if writeAccess then
        writeFlag <= '1', '0' after clockPeriod + 1 ns;
        writeData <= registerData;
      else
      readFlag <= '1', '0' after clockPeriod + 1 ns;
      end if;
    end if;
  end process busAccess1;

  hWrite <= writeFlag;
                                                          -- phase 2: data write
  busAccess2: process
  begin
    wait until rising_edge(clock_int);
    hWData <= (others => '-');
    readFlag1 <= '0';
    if writeFlag = '1' then
      hWData <= std_uLogic_vector(to_signed(writeData, hWData'length));
    end if;
    readFlag1 <= readFlag;
  end process busAccess2;
                                                           -- phase 3: data read
  busAccess3: process
  begin
    wait until rising_edge(clock_int);
    if readFlag1 = '1' then
      readData <= to_integer(to_01(unsigned(hRData)));
    end if;
  end process busAccess3;

  ------------------------------------------------------------------------------
                                                                  -- GPIO access
  linesAccess: process(ioData, ioMask)
    variable ioDataVector: unsigned(io'range);
    variable ioMaskVector: unsigned(io'range);
  begin
    ioDataVector := to_unsigned(ioData, ioDataVector'length);
    ioMaskVector := to_unsigned(ioMask, ioMaskVector'length);
    for index in io'range loop
      if ioMaskVector(index) = '1' then
        io(index) <= 'Z';
      else
        io(index) <= ioDataVector(index);
      end if;
    end loop;
  end process;

END ARCHITECTURE test;
