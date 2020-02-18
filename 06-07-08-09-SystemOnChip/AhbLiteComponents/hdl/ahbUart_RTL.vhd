--==============================================================================
--
-- AHB UART
--
-- Implements a serial port.
--
--------------------------------------------------------------------------------
--
-- Write registers
--
-- 00, data register receives the word to be sent to the serial port.
-- 01, control register is used to control the peripheral.
-- 02, scaler register is used to set the baud rate.
--
--------------------------------------------------------------------------------
--
-- Read registers
-- 00, data register provides the last word received by the serial port.
-- 01, status register is used to get the peripheral's state.
--     bit 0: data ready for read
--     bit 1: sending in progress
--     bit 2: receiving in progress
--

ARCHITECTURE RTL OF ahbUart IS

  signal reset, clock: std_ulogic;
                                                         -- register definitions
  constant dataOutRegisterId: natural := 0;
  constant dataBitNb: positive := 8;
  constant controlRegisterId: natural := 1;
  constant controlBpoId: natural := 0;
  constant controlFormatId: natural := 0;
  constant scalerRegisterId: natural := 2;

  constant statusRegisterId: natural := 1;
  constant statusReadyId: natural := 0;
  constant statusSendingId: natural := 1;
  constant statusReceivingId: natural := 2;
                                                            -- written registers
  signal addressReg: unsigned(addressBitNb(scalerRegisterId)+1-1 downto 0);
  signal writeReg: std_ulogic;
  signal readReg: std_ulogic;
  subtype registerType is unsigned(hWdata'length-1 downto 0);
  signal dataOutRegister : unsigned(dataBitNb-1 downto 0);
  signal controlRegister, scalerRegister: registerType;
                                                                   -- serializer
  signal txPeriodCounter: unsigned(registerType'range);
  signal txEn: std_uLogic;
  signal txStart: std_uLogic;
  signal txSending: std_uLogic;
  signal txShiftCounter : unsigned(addressBitNb(dataOutRegister'length+2)-1 downto 0);
  signal txShiftRegister : unsigned(dataOutRegister'high+1 downto 0);
                                                               -- read registers
  signal dataInRegister : unsigned(dataOutRegister'range);
  signal statusRegister: registerType;
                                                                 -- deserializer
  signal rxPeriodCounter: unsigned(registerType'range);
  signal rxEn: std_uLogic;
  signal rxDelayed, rxChanged: std_uLogic;
  signal rxShiftCounter : unsigned(txShiftCounter'range);
  signal rxReceiving: std_uLogic;
  signal rxShiftRegister : unsigned(dataInRegister'range);
  signal rxDataReady: std_uLogic;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= not hReset_n;
  clock <= hClk;

  --============================================================================
                                                         -- address and controls
  storeControls: process(reset, clock)
  begin
    if reset = '1' then
      addressReg <= (others => '0');
      writeReg <= '0';
      readReg <= '0';
    elsif rising_edge(clock) then
      writeReg <= '0';
      readReg <= '0';
      if (hSel = '1') and (hTrans = transNonSeq) then
        addressReg <= hAddr(addressReg'range);
        writeReg <= hWrite;
        readReg <= not hWrite;
      end if;
    end if;
  end process storeControls;

  --============================================================================
                                                                    -- registers
  storeWriteRegisters: process(reset, clock)
  begin
    if reset = '1' then
      dataOutRegister <= (others => '0');
      controlRegister <= (others => '0');
      scalerRegister <= (others => '0');
    elsif rising_edge(clock) then
      if writeReg = '1' then
        case to_integer(addressReg) is
          when dataOutRegisterId    => dataOutRegister <= unsigned(hWData(dataOutRegister'range));
          when controlRegisterId => controlRegister <= unsigned(hWData);
          when scalerRegisterId  => scalerRegister <= unsigned(hWData);
          when others => null;
        end case;
      end if;
    end if;
  end process storeWriteRegisters;

  txStart <= '1' when (writeReg = '1') and (addressReg = dataOutRegisterId)
    else '0';

  --============================================================================
                                                                   -- serializer
                                                                 -- tx baud rate
  countTxBaudRate: process(reset, clock)
  begin
    if reset = '1' then
      txPeriodCounter <= (others => '1');
    elsif rising_edge(clock) then
      if txPeriodCounter + 1 < scalerRegister then
        txPeriodCounter <= txPeriodCounter + 1;
      else
        txPeriodCounter <= (others => '0');
      end if;
    end if;
  end process countTxBaudRate;

  txEn <= '1' when txPeriodCounter = 1
    else '0';
                                                               -- count tx shift
  countTxShift: process(reset, clock)
  begin
    if reset = '1' then
      txShiftCounter <= (others => '0');
    elsif rising_edge(clock) then
      if txShiftCounter = 0 then
        if txStart = '1' then
          txShiftCounter <= txShiftCounter + 1;
        end if;
      elsif txEn = '1' then
        if txShiftCounter < dataOutRegister'length + 3 then
          txShiftCounter <= txShiftCounter + 1;
        else
          txShiftCounter <= (others => '0');
        end if;
      end if;
    end if;
  end process countTxShift;

  txSending <= '1' when txShiftCounter /= 0
    else '0';
                                                                -- tx serializer
  shiftTxData: process(reset, clock)
  begin
    if reset = '1' then
      txShiftRegister <= (others => '1');
    elsif rising_edge(clock) then
      if txEn = '1' then
        if txShiftCounter = 1 then
          txShiftRegister <= dataOutRegister & '0';
        else
          txShiftRegister <= shift_right(txShiftRegister, 1);
          txShiftRegister(txShiftRegister'high) <= '1';
        end if;
      end if;
    end if;
  end process shiftTxData;

  TxD <= txShiftRegister(0);

  --============================================================================
                                                                 -- deserializer
  delayRxd: process(reset, clock)
  begin
    if reset = '1' then
      rxDelayed <= '0';
    elsif rising_edge(clock) then
      rxDelayed <= RxD;
    end if;
  end process delayRxd;

  rxChanged <= '1' when rxDelayed /= RxD
    else '0';
                                                                 -- rx baud rate
  countRxBaudRate: process(reset, clock)
  begin
    if reset = '1' then
      rxPeriodCounter <= (others => '1');
    elsif rising_edge(clock) then
      if rxChanged = '1' then
        rxPeriodCounter <= (others => '0');
      elsif rxPeriodCounter + 1 < scalerRegister then
        rxPeriodCounter <= rxPeriodCounter + 1;
      else
        rxPeriodCounter <= (others => '0');
      end if;
    end if;
  end process countRxBaudRate;

  rxEn <= '1' when rxPeriodCounter = shift_right(scalerRegister-2, 1)
    else '0';
                                                               -- count rx shift
  countRxShift: process(reset, clock)
  begin
    if reset = '1' then
      rxShiftCounter <= (others => '0');
    elsif rising_edge(clock) then
      if rxShiftCounter = 0 then
        if (RxD = '0') and (rxDelayed = '1') then
          rxShiftCounter <= rxShiftCounter + 1;
        end if;
      elsif rxEn = '1' then
        if rxShiftCounter < dataInRegister'length + 2 then
          rxShiftCounter <= rxShiftCounter + 1;
        else
          rxShiftCounter <= (others => '0');
        end if;
      end if;
    end if;
  end process countRxShift;

  rxReceiving <= '1' when rxShiftCounter /= 0
    else '0';
                                                              -- rx deserializer
  shiftRxData: process(reset, clock)
  begin
    if reset = '1' then
      rxShiftRegister <= (others => '1');
      dataInRegister <= (others => '0');
    elsif rising_edge(clock) then
      if rxEn = '1' then
        if rxShiftCounter <= dataInRegister'length+1 then
          rxShiftRegister <= shift_right(rxShiftRegister, 1);
          rxShiftRegister(rxShiftRegister'high) <= RxD;
        end if;
        if rxShiftCounter = dataInRegister'length+2 then
          dataInRegister <= rxShiftRegister;
        end if;
      end if;
    end if;
  end process shiftRxData;
                                                           -- monitor data ready
  checkDataReady: process(reset, clock)
  begin
    if reset = '1' then
      rxDataReady <= '0';
    elsif rising_edge(clock) then
      if (rxEn = '1') and (rxShiftCounter = dataInRegister'length+2) then
        rxDataReady <= '1';
      elsif (readReg = '1') and (addressReg = dataOutRegisterId) then
        rxDataReady <= '0';
      end if;
    end if;
  end process checkDataReady;

  --============================================================================
                                                                -- data readback
  statusRegister <= (
    statusReadyId     => rxDataReady,
    statusSendingId   => txSending,
    statusReceivingId => rxReceiving,
    others            => '0'
  );

  selectData: process(addressReg, dataInRegister, statusRegister)
  begin
    hRData <= (others => '-');
    case to_integer(addressReg) is
      when dataOutRegisterId => hRData <= std_ulogic_vector(resize(dataInRegister, hRData'length));
      when statusRegisterId  => hRData <= std_ulogic_vector(statusRegister);
      when others => null;
    end case;
  end process selectData;

  hReady <= '1';  -- no wait state
  hResp  <= '0';  -- data OK
  

END ARCHITECTURE RTL;
