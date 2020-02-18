LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE RTL OF uvmAhbMonitor IS

  signal addressReg: unsigned(hAddr'range);
  signal writeReg: std_ulogic;
  signal readReg: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                -- register address and controls
  storeControls: process(hReset_n, hClk)
  begin
    if not(hReset_n) = '1' then
      addressReg <= (others => '0');
      writeReg <= '0';
      readReg <= '0';
    elsif rising_edge(hClk) then
      writeReg <= '0';
      readReg <= '0';
      if (hSel = '1') and (hTrans = transNonSeq) then
        addressReg <= hAddr(addressReg'range);
        writeReg <= hWrite;
        readReg <= not hWrite;
      end if;
    end if;
  end process storeControls;
                                                              -- monitor acesses
  reportBusAccess: process(hReset_n, hClk)
  begin
    if not(hReset_n) = '1' then
      monitorTransaction <= pad( false, ' ', monitorTransaction'length, "idle");
    elsif rising_edge(hClk) then
      if readReg = '1' then
        monitorTransaction <= pad(
          false, ' ', monitorTransaction'length,
          "read " & sprintf("%04X", addressReg) & ' ' & sprintf("%04X", hRData)
        );
      elsif writeReg = '1' then
        monitorTransaction <= pad(
          false, ' ', monitorTransaction'length,
          "written " & sprintf("%04X", addressReg) & ' ' & sprintf("%04X", hWData)
        );
      end if;
    end if;
  end process reportBusAccess;

END ARCHITECTURE RTL;
