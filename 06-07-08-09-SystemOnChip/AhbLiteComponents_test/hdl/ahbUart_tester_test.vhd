LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE test OF ahbUart_tester IS
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
  constant dataRegisterAddress: natural := 0;
  constant controlRegisterAddress: natural := 1;
  constant scalerRegisterAddress: natural := 2;

  constant statusRegisterAddress: natural := 1;
  constant statusValidAddress: natural := 0;
  constant valueRegisterAddress: natural := 1;
                                                              -- AMBA bus access
  signal registerAddress: natural;
  signal registerData: integer;
  signal registerWrite: std_uLogic;
  signal registerRead: std_uLogic;
  signal writeFlag, readFlag, readFlag1: std_uLogic;
  signal writeData, readData: integer;
                                                                  -- UART access
  constant baudPeriodNb: positive := 4;
  signal uartData: integer;
  signal uartSend: std_uLogic;

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
    uartSend <= '0';
    wait for 1 us;
                                                              -- write baud rate
    testInformation <= pad("Writing baud rate", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    registerAddress <= scalerRegisterAddress;
    registerData <= baudPeriodNb;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 4*clockPeriod;
                                                            -- write Tx data 55h
    testInformation <= pad("Writing Tx data", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    registerAddress <= dataRegisterAddress;
    registerData <= 16#55#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 20*baudPeriodNb*clockPeriod;
                                                            -- write Tx data 0Fh
    testInformation <= (others => ' ');
    wait for 1 ns;
    testInformation <= pad("Writing Tx data", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    registerAddress <= dataRegisterAddress;
    registerData <= 16#0F#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 4*clockPeriod;
                                                                  -- read status
    testInformation <= pad("Reading status", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    registerAddress <= statusRegisterAddress;
    registerRead <= '1', '0' after clockPeriod;
    for index in 1 to 4 loop
      wait until rising_edge(clock_int);
    end loop;
    assert readData = 16#02#
      report
        errorTopSeparator & cr &
        errorInformation & indentation &
        "expected status sending flag" & cr &
        errorInformation & bottomSeparator
      severity error;
    wait for 12*baudPeriodNb*clockPeriod;
                                                                  -- read status
    testInformation <= (others => ' ');
    wait for 1 ns;
    testInformation <= pad("Reading status", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    registerRead <= '1', '0' after clockPeriod;
    for index in 1 to 4 loop
      wait until rising_edge(clock_int);
    end loop;
    assert readData = 16#00#
      report
        errorTopSeparator & cr &
        errorInformation & indentation &
        "expected no flag" & cr &
        errorInformation & bottomSeparator
      severity error;
    wait for 20*baudPeriodNb*clockPeriod;
                                                                  -- receive AAh
    testInformation <= pad("Receiving Rx data", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    uartData <= 16#AA#;
    uartSend <= '1', '0' after clockPeriod;
    wait for 4*clockPeriod;
                                                                  -- read status
    testInformation <= pad("Reading status", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    registerAddress <= statusRegisterAddress;
    registerRead <= '1', '0' after clockPeriod;
    for index in 1 to 4 loop
      wait until rising_edge(clock_int);
    end loop;
    assert readData = 16#04#
      report
        errorTopSeparator & cr &
        errorInformation & indentation &
        "expected status receiving flag" & cr &
        errorInformation & bottomSeparator
      severity error;
    wait for 10*baudPeriodNb*clockPeriod;
                                                            -- read status again
    testInformation <= (others => ' ');
    wait for 1 ns;
    testInformation <= pad("Reading status", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    registerRead <= '1', '0' after clockPeriod;
    for index in 1 to 4 loop
      wait until rising_edge(clock_int);
    end loop;
    assert readData = 16#01#
      report
        errorTopSeparator & cr &
        errorInformation & indentation &
        "expected status data available flag" & cr &
        errorInformation & bottomSeparator
      severity error;
    wait for 4*clockPeriod;
                                                                    -- read data
    testInformation <= pad("Reading data", testInformation'length);
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
    assert readData = 16#AA#
      report
        errorTopSeparator & cr &
        errorInformation & indentation & "read data not as expected" & cr &
        errorInformation & bottomSeparator
      severity error;
    wait for 4*clockPeriod;
                                                                  -- read status
    testInformation <= pad("Reading status", testInformation'length);
    wait for 0 ns;
    assert false
      report
        noteTopSeparator & cr &
        noteInformation & indentation & testInformation & cr &
        noteInformation & bottomSeparator
      severity note;
    registerAddress <= statusRegisterAddress;
    registerRead <= '1', '0' after clockPeriod;
    for index in 1 to 4 loop
      wait until rising_edge(clock_int);
    end loop;
    assert readData = 16#00#
      report
        errorTopSeparator & cr &
        errorInformation & indentation &
        "expected no flag" & cr &
        errorInformation & bottomSeparator
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
                                                                  -- UART access
  sendByte: process
    variable serialData: unsigned(7 downto 0);
  begin
                                                                 -- send stop bit
    RxD <= '1';
                                                                 -- get new word
    wait until rising_edge(uartSend);
    serialData := to_unsigned(uartData, serialData'length);
                                                                -- send start bit
    RxD <= '0';
    wait for baudPeriodNb * clockPeriod;
                                                                -- send data bits
    for index in serialData'reverse_range loop
      RxD <= serialData(index);
      wait for baudPeriodNb * clockPeriod;
    end loop;
  end process sendByte;

END ARCHITECTURE test;
