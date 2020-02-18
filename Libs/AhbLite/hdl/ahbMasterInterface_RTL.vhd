ARCHITECTURE RTL OF ahbMasterInterface IS

  signal addressReg: unsigned(pAddress'range);
  signal newAddress: std_ulogic;
  signal writeReg: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  hReset_n <= not reset;
  hClk <= clock;

  ------------------------------------------------------------------------------
                                                         -- address and controls
  newAddress <= pReadStrobe or pWriteStrobe;

  storeAddress: process(reset, clock)
  begin
    if reset = '1' then
      addressReg <= (others => '0');
    elsif rising_edge(clock) then
      if newAddress = '1' then
        addressReg <= pAddress;
      end if;
    end if;
  end process storeAddress;

  hAddr <= pAddress when newAddress = '1'
    else addressReg;

  storeWrite: process(reset, clock)
  begin
    if reset = '1' then
      writeReg <= '0';
    elsif rising_edge(clock) then
      if newAddress = '1' then
        writeReg <= pWriteStrobe;
      end if;
    end if;
  end process storeWrite;

  hWrite <= pWriteStrobe when newAddress = '1'
    else writeReg;

  hTrans <= transNonSeq when newAddress = '1'
    else transIdle;

  hSize <= size16;
  hBurst <= burstSingle;
  hProt <= protDefault;
  hMastLock <= '0';

  ------------------------------------------------------------------------------
                                                                     -- data out
  delayData: process(reset, clock)
  begin
    if reset = '1' then
      hWData <= (others => '0');
    elsif rising_edge(clock) then
      if pWriteStrobe = '1' then
        hWData <= pDataOut;
      end if;
    end if;
  end process delayData;

  ------------------------------------------------------------------------------
                                                                      -- data in
  pDataIn <= hRData;

END ARCHITECTURE RTL;
