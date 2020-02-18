LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE test OF ahbBeamer_tester IS
                                                              -- reset and clock
  constant clockFrequency: real := 100.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';
  signal reset_int: std_uLogic;
                                                             -- test information
  signal testSeparator : string(1 to 80) := (others => '-');
  signal errorTopSeparator : string(1 to 80) := (others => '#');
  signal bottomSeparator : string(1 to 80) := (others => '.');
  signal indentation : string(1 to 2) := (others => ' ');
  signal noteInformation : string(1 to 9) := (others => ' ');
  signal errorInformation : string(1 to 10) := (others => ' ');
  signal failureInformation : string(1 to 12) := (others => ' ');
  signal testInformation : string(1 to 50) := (others => ' ');
                                                          -- register definition
  constant controlRegisterAddress: natural := 0;
  constant controlRun: natural := 2#001#;
  constant controlUpdatePattern: natural := 2#010#;
  constant controlInterpolateLinear: natural := 2#100#;
  constant speedRegisterAddress: natural := 1;
  constant xFifoRegisterAddress: natural := 2;
  constant yFifoRegisterAddress: natural := 3;
  signal updatePeriod: natural := 1;
  signal patternLength: natural := 32;
                                                              -- AMBA bus access
  constant registerWriteDelay: time := 4*clockPeriod;
  signal registerAddress: natural;
  signal registerDataOut, registerDataIn: integer;
  signal registerWrite: std_uLogic;
  signal registerRead: std_uLogic;
                                                                  -- UART access
  constant baudPeriodNb: positive := 4;
  signal uartData: integer;
  signal uartSend: std_uLogic;
                                                                    -- functions
  function clearBits (word, bits : natural) return natural is
    variable andMask: unsigned(hRData'range);
  begin
    andMask := not(to_unsigned(bits, hRData'length));
    return to_integer(to_unsigned(word, hRData'length) and andMask);
  end clearBits; 

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset_int <= '1', '0' after 2*clockPeriod;
  hReset_n <= not(reset_int);
  reset <= reset_int;

  clock_int <= not clock_int after clockPeriod/2;
  hClk <= transport clock_int after clockPeriod*9.0/10.0;
  clock <= transport clock_int after clockPeriod*9.0/10.0;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  testSequence: process
  begin
    selSinCos <= '0';
    registerAddress <= 0;
    registerDataOut <= 0;
    registerWrite <= '0';
    registerRead <= '0';
    uartSend <= '0';
    wait for 100 ns;
    print(cr & cr & cr & cr);

    ----------------------------------------------------------------------------
                                                        -- test control register
    wait for 1 us - now;
    testInformation <= pad("Testing control register", testInformation'length);
    wait for 0 ns;
    print(testSeparator & cr & testInformation);
                                                    -- set control register bits
    wait until rising_edge(clock_int);
    registerAddress <= controlRegisterAddress;
    registerDataOut <= controlRun + controlUpdatePattern + controlInterpolateLinear;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
                                                    -- readback control register
    wait until rising_edge(clock_int);
    registerAddress <= controlRegisterAddress;
    registerRead <= '1', '0' after clockPeriod;
    wait for 3*clockPeriod;
    assert(registerDataIn = controlRun + controlUpdatePattern + controlInterpolateLinear)
      report "Control register write / readback error"
      severity error;
    wait for registerWriteDelay;
                                              -- stop running and pattern update
    wait until rising_edge(clock_int);
    registerAddress <= controlRegisterAddress;
    registerRead <= '1', '0' after clockPeriod;
    wait for 3*clockPeriod;
    registerDataOut <= clearBits(registerDataIn, controlRun + controlUpdatePattern);
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;

    ----------------------------------------------------------------------------
                                                          -- test speed register
    wait for 2 us - now;
    testInformation <= pad("Testing speed register", testInformation'length);
    wait for 0 ns;
    print(testSeparator & cr & testInformation);
                                                        -- set speed count value
    wait until rising_edge(clock_int);
    registerAddress <= speedRegisterAddress;
    registerDataOut <= updatePeriod;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
                                                         -- readback speed count
    wait until rising_edge(clock_int);
    registerAddress <= speedRegisterAddress;
    registerRead <= '1', '0' after clockPeriod;
    wait for 3*clockPeriod;
    assert(registerDataIn = updatePeriod)
      report "Speed register write / readback error"
      severity error;
    wait for registerWriteDelay;

    ----------------------------------------------------------------------------
                                            -- write sinewave data points to RAM
    wait for 3 us - now;
    testInformation <= pad("Writing sinewaves to RAM", testInformation'length);
    wait for 0 ns;
    print(testSeparator & cr & testInformation);
                                                         -- start pattern update
    wait until rising_edge(clock_int);
    registerAddress <= controlRegisterAddress;
    registerDataOut <= controlUpdatePattern;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
                                                          -- write X FIFO values
    wait until rising_edge(clock_int);
    registerAddress <= xFifoRegisterAddress;
    registerDataOut <= 16#0000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#18F9#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#30FB#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#471C#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#5A82#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#6A6D#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#7641#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#7D89#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#7FFF#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#7D89#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#7641#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#6A6D#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#5A82#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#471C#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#30FB#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#18F9#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#0000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#18F9#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#30FB#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#471C#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#5A82#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#6A6D#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7641#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7D89#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7FFF#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7D89#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7641#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#6A6D#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#5A82#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#471C#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#30FB#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#18F9#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 10*registerWriteDelay;
                                                          -- write Y FIFO values
    wait until rising_edge(clock_int);
    registerAddress <= yFifoRegisterAddress;
    registerDataOut <= 16#7FFF#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#7D89#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#7641#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#6A6D#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#5A82#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#471C#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#30FB#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#18F9#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#0000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#18F9#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#30FB#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#471C#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#5A82#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#6A6D#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7641#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7D89#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7FFF#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7D89#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7641#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#6A6D#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#5A82#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#471C#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#30FB#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#18F9#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#0000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#18F9#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#30FB#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#471C#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#5A82#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#6A6D#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#7641#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= 16#7D89#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 10*registerWriteDelay;
                                                           -- end pattern update
    wait until rising_edge(clock_int);
    registerAddress <= controlRegisterAddress;
    registerDataOut <= 0;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;

    ----------------------------------------------------------------------------
                                                            -- playing waveforms
    wait for 7 us - now;
    testInformation <= pad("Playing waveforms", testInformation'length);
    wait for 0 ns;
    print(testSeparator & cr & testInformation);
                                                                    -- start run
    wait until rising_edge(clock_int);
    registerAddress <= controlRegisterAddress;
    registerDataOut <= controlRun + patternLength * 2**(hWData'length-patternAddressBitNb);
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
                                                            -- run for some time
    wait for 250 us - now;
                                                                     -- stop run
    wait until rising_edge(clock_int);
    registerAddress <= controlRegisterAddress;
    registerDataOut <= 0;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;

    ----------------------------------------------------------------------------
                                         -- play data points to RAM for overflow
    wait for 300 us - now;
    testInformation <= pad(
      "Writing waveform to RAM for overflow", testInformation'length
    );
    wait for 0 ns;
    print(testSeparator & cr & testInformation);
                                                         -- start pattern update
    wait until rising_edge(clock_int);
    registerAddress <= controlRegisterAddress;
    registerDataOut <= controlUpdatePattern;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
                                                          -- write X FIFO values
    wait until rising_edge(clock_int);
    registerAddress <= xFifoRegisterAddress;
    registerDataOut <=  16#4000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <=  16#7000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 10*registerWriteDelay;
                                                          -- write Y FIFO values
    wait until rising_edge(clock_int);
    registerAddress <= yFifoRegisterAddress;
    registerDataOut <= -16#4000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <=  16#7000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <=  16#7000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    registerDataOut <= -16#7000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 10*registerWriteDelay;
                                             -- end pattern update and start run
    patternLength <= 4;
    wait until rising_edge(clock_int);
    registerAddress <= controlRegisterAddress;
    registerDataOut <= controlRun + patternLength * 2**(hWData'length-patternAddressBitNb);
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
                                                    -- set lower speed execution
    updatePeriod <= 9;
    wait until rising_edge(clock_int);
    registerAddress <= speedRegisterAddress;
    registerDataOut <= updatePeriod;
    registerWrite <= '1', '0' after clockPeriod;
    wait for registerWriteDelay;
    ----------------------------------------------------------------------------
                                                           -- sin/cos debug mode
    wait for 700 us - now;
    testInformation <= pad("Drawing debug mode circle", testInformation'length);
    wait for 0 ns;
    print(testSeparator & cr & testInformation);
    selSinCos <= '1';
    ----------------------------------------------------------------------------
                                                            -- end of simulation
    wait;
  end process testSequence;

  ------------------------------------------------------------------------------
                                                              -- AMBA bus access
  busAccess: process
    variable writeAccess: boolean;
    variable hRData01: std_ulogic_vector(hRData'range);
  begin
    hAddr <= (others => '-');
    hWData <= (others => '-');
    hTrans <= transIdle;
    hSel <= '0';
    hWrite <= '0';
    wait on registerWrite, registerRead;
    writeAccess := false;
    if rising_edge(registerWrite) then
      writeAccess := true;
    end if;
                                                -- phase 1: address and controls
    wait until rising_edge(clock_int);
    hAddr <= to_unsigned(registerAddress, hAddr'length);
    hTrans <= transNonSeq;
    hSel <= '1';
    if writeAccess then
      hWrite <= '1';
    end if;
                                                                -- phase 2: data
    wait until rising_edge(clock_int);
    hAddr <= (others => '-');
    hTrans <= transIdle;
    hSel <= '0';
    hWrite <= '0';
    if writeAccess then
      hWData <= std_uLogic_vector(to_signed(registerDataOut, hWData'length));
    else
      wait until falling_edge(clock_int);
      hRData01 := hRData;
      for index in hRData01'range loop
        if (hRData01(index) /= '0') and (hRData01(index) /= '1') then
          hRData01(index) := '0';
        end if;
      end loop;
      registerDataIn <= to_integer(unsigned(hRData01));
    end if;
    wait until rising_edge(clock_int);
  end process;

END ARCHITECTURE test;
