ARCHITECTURE test OF beamerSoc_tester IS
                                                              -- clock and reset
  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';
  signal sReset: std_uLogic := '1';
                                                          -- register definition
  constant beamerBaseAddress: natural := 16#20#;
  constant beamerControlRegisterAddress: natural := beamerBaseAddress + 0;
  constant beamerControlRun: natural := 2#001#;
  constant beamerControlUpdatePattern: natural := 2#010#;
  constant beamerControlInterpolateLinear: natural := 2#100#;
  constant beamerControlsizeBase: natural := 16#80#;
  constant beamerSpeedRegisterAddress: natural := beamerBaseAddress + 1;
  constant beamerXFifoRegisterAddress: natural := beamerBaseAddress + 2;
  constant beamerYFifoRegisterAddress: natural := beamerBaseAddress + 3;
                                                    -- microprocessor bus access
  constant registerWriteDelay: time := 4*clockPeriod;
  signal registerAddress: natural;
  signal registerDataOut, registerDataIn: integer;
  signal registerWrite, registerRead, registerDone: std_uLogic;
                                                                  -- UART access
--  constant uartFrequency: real := 115200.0;
  constant uartDataBitNb: positive := 8;
  constant uartFrequency: real := 1.0E6;
  constant uartPeriod: time := (1.0/uartFrequency) * 1 sec;
  constant uartDataSpan: time := 10*uartPeriod;
  constant uartWriteReplySpan: time := 5*uartDataSpan;
  constant uartReadReplySpan: time := 10*uartDataSpan;
  signal uartRxData, uartTxData: integer;
  signal uartSend, uartDone: std_uLogic;
  signal uartTxShiftRegister: unsigned(2*uartDataBitNb-1 downto 0);
  signal uartTxDataWord: integer;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;

  reset <= '1', '0' after 2*clockPeriod;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  process
  begin
    io <= (others => 'Z');
    selSinCos <= '0';
    wait for 1 ns;
    assert false
      report cr & cr & cr & cr &
             "----------------------------------------" &
             "----------------------------------------" &
             "----------------------------------------"
      severity note;
    ----------------------------------------------------------------------------
                                             -- initialization by microprocessor
    wait for 100 ns - now;
    assert false
      report "Init" & cr & "     --> " &
             "Letting the microprocessor initialize the peripherals"
      severity note;
    ----------------------------------------------------------------------------
                                                                   -- test GPIOs
    wait for 400 ns - now;
    assert false
      report "GPIOs" & cr & "     --> " &
             "Testing the GPIOs"
      severity note;
    io(7 downto 4) <= x"5";
    wait for 1 ns;
    assert io = x"5A"
      report "GPIO error"
      severity error;
    ----------------------------------------------------------------------------
                                                        -- set speed count value
    wait for 3*uartPeriod - now;
    assert false
      report "Beamer init" & cr & "     --> " &
             "Setting drawing speed"
      severity note;
    registerAddress <= beamerSpeedRegisterAddress;
    registerDataOut <= 2;
--registerAddress <= 16#1234#;
--registerDataOut <= 16#5678#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for uartPeriod;
    wait until registerDone = '1';
    wait for uartWriteReplySpan;
    ----------------------------------------------------------------------------
                                                       -- start updating pattern
    assert false
      report "Beamer init" & cr & "     --> " &
             "Writing y-pattern to beamer RAM"
      severity note;
    registerAddress <= beamerControlRegisterAddress;
    registerDataOut <= beamerControlUpdatePattern;
    registerWrite <= '1', '0' after clockPeriod;
    wait for uartPeriod;
    wait until registerDone = '1';
    wait for uartWriteReplySpan;
    ----------------------------------------------------------------------------
                                                                 -- write y-FIFO
    registerAddress <= beamerYFifoRegisterAddress;
    registerDataOut <= -16#4000# + 16#10000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for uartPeriod;
    wait until registerDone = '1';
    wait for uartWriteReplySpan;
    registerDataOut <=  16#7000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for uartPeriod;
    wait until registerDone = '1';
    wait for uartWriteReplySpan;
    registerDataOut <=  16#7000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for uartPeriod;
    wait until registerDone = '1';
    wait for uartWriteReplySpan;
    registerDataOut <= -16#7000# + 16#10000#;
    registerWrite <= '1', '0' after clockPeriod;
    wait for uartPeriod;
    wait until registerDone = '1';
    wait for uartWriteReplySpan;
    ----------------------------------------------------------------------------
                                                                    -- start run
    assert false
      report "Beamer play" & cr & "     --> " &
             "Launching pattern drawing (setting pattern size and run flag)"
      severity note;
    registerAddress <= beamerControlRegisterAddress;
    registerDataOut <= beamerControlRun + beamerControlsizeBase * 4;
    registerWrite <= '1', '0' after clockPeriod;
    wait for uartPeriod;
    wait until registerDone = '1';
    wait for uartWriteReplySpan;
    ----------------------------------------------------------------------------
                                                    -- readback control register
    assert false
      report "Beamer test" & cr & "     --> " &
             "Reading back control register"
      severity note;
    registerAddress <= beamerControlRegisterAddress;
    registerRead <= '1', '0' after clockPeriod;
    wait for uartPeriod;
    wait until registerDone = '1';
    wait for uartReadReplySpan;
    assert uartTxDataWord = beamerControlRun + beamerControlsizeBase * 4
      report "Beamer register readback error"
      severity error;
    ----------------------------------------------------------------------------
                                                              -- stop simulation
    wait for 1.5 ms - now;
    assert false
      report "End" & cr & "     --> " &
             "End of simulation"
      severity failure;
  end process;

  --============================================================================
                                                    -- microprocessor bus access
  busAccess: process
    variable writeAccess: boolean;
--    variable packetId: natural := 0;
variable packetId: natural := 16#1D#;
    variable checksum: natural;
  begin
    registerDone <= '1';
    uartSend <= '0';
    uartRxData <= 16#AA#;
    wait on registerWrite, registerRead;
    registerDone <= '0';
    writeAccess := false;
    if registerWrite = '1' then
      writeAccess := true;
    end if;
                                                                  -- send header
    uartSend <= '1', '0' after uartPeriod;
    wait for uartPeriod;
    wait until uartDone = '1';
    checksum := uartRxData;
                                                               -- send packet id
    uartRxData <= packetId;
    packetId := (packetId + 1) mod 2**8;
    uartSend <= '1', '0' after uartPeriod;
    wait for uartPeriod;
    wait until uartDone = '1';
    checksum := (checksum + uartRxData) mod 2**8;
                                                                 -- send command
    if writeAccess then
      uartRxData <= 16#03#;
    else
      uartRxData <= 16#04#;
    end if;
    uartSend <= '1', '0' after uartPeriod;
    wait for uartPeriod;
    wait until uartDone = '1';
    checksum := (checksum + uartRxData) mod 2**8;
                                                             -- send data length
    if writeAccess then
      uartRxData <= 4;
    else
      uartRxData <= 2;
    end if;
    uartSend <= '1', '0' after uartPeriod;
    wait for uartPeriod;
    wait until uartDone = '1';
    checksum := (checksum + uartRxData) mod 2**8;
                                                            -- send addresss low
    uartRxData <= registerAddress mod 2**8;
    uartSend <= '1', '0' after uartPeriod;
    wait for uartPeriod;
    wait until uartDone = '1';
    checksum := (checksum + uartRxData) mod 2**8;
                                                           -- send addresss high
    uartRxData <= registerAddress / 2**8;
    uartSend <= '1', '0' after uartPeriod;
    wait for uartPeriod;
    wait until uartDone = '1';
    checksum := (checksum + uartRxData) mod 2**8;
                                                                -- send data low
    if writeAccess then
      uartRxData <= registerDataOut mod 2**8;
      uartSend <= '1', '0' after uartPeriod;
      wait for uartPeriod;
      wait until uartDone = '1';
      checksum := (checksum + uartRxData) mod 2**8;
                                                               -- send data high
      uartRxData <= registerDataOut / 2**8;
      uartSend <= '1', '0' after uartPeriod;
      wait for uartPeriod;
      wait until uartDone = '1';
      checksum := (checksum + uartRxData) mod 2**8;
    end if;
                                                                -- send checksum
    uartRxData <= checksum;
    uartSend <= '1', '0' after uartPeriod;
    wait for uartPeriod;
    wait until uartDone = '1';
  end process;

  ------------------------------------------------------------------------------
                                                                  -- UART access
  sendByte: process
    variable serialData: unsigned(7 downto 0);
  begin
                                                                -- send stop bit
    uartDone <= '1';
    RxD <= '1';
                                                                 -- get new word
    wait until rising_edge(uartSend);
    uartDone <= '0';
    serialData := to_unsigned(uartRxData, serialData'length);
                                                               -- send start bit
    RxD <= '0';
    wait for uartPeriod;
                                                               -- send data bits
    for index in serialData'reverse_range loop
      RxD <= serialData(index);
      wait for uartPeriod;
    end loop;
                                                               -- send stop bits
    RxD <= '1';
    wait for 4*uartPeriod;
  end process sendByte;

  ------------------------------------------------------------------------------
                                                                  -- UART access
  receiveByte: process
    variable serialData: unsigned(uartDataBitNb-1 downto 0);
  begin
                                                            -- wait for stat bit
    wait until falling_edge(TxD);
                                             -- jump to middle of first data bit
    wait for 1.5 * uartPeriod;
                                                               -- read data bits
    for index in serialData'reverse_range loop
      if Is_X(TxD) then
        serialData(index) := '0';
      else
        serialData(index) := TxD;
      end if;
      wait for uartPeriod;
    end loop;
                                                         -- write data to signal
    uartTxData <= to_integer(serialData);
    uartTxDataWord <= to_integer(uartTxShiftRegister);
    uartTxShiftRegister <= shift_right(uartTxShiftRegister, serialData'length);
    uartTxShiftRegister(
      uartTxShiftRegister'high downto
      uartTxShiftRegister'high-serialData'length+1
    ) <= serialData;
  end process receiveByte;

END ARCHITECTURE test;
