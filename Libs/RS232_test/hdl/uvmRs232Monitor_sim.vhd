LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE RTL OF uvmRs232Monitor IS

  constant uartDataBitNb: positive := 8;
  signal baudPeriod: time;
  signal rxWord, txWord: natural;
  signal startup, rxReceived, txReceived: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
  baudPeriod <= 1.0/baudRate * 1 sec;

  ------------------------------------------------------------------------------
                                                                  -- receive RxD
  receiveRxD: process
    variable rxData: unsigned(uartDataBitNb-1 downto 0);
  begin
    rxReceived <= '0';
                                                                    -- start bit
    wait until falling_edge(RxD);
    wait for 1.5 * baudPeriod;
                                                                    -- data bits
    for index in rxData'reverse_range loop
      rxData(index) := RxD;
      wait for baudPeriod;
    end loop;
                                                            -- store information
    rxWord <= to_integer(rxData);
    rxReceived <= '1';
    wait for 0 ns;
  end process receiveRxD;

  ------------------------------------------------------------------------------
                                                                  -- receive RxD
  receiveTxD: process
    variable txData: unsigned(uartDataBitNb-1 downto 0);
  begin
    txReceived <= '0';
                                                                    -- start bit
    wait until falling_edge(TxD);
    wait for 1.5 * baudPeriod;
                                                                    -- data bits
    for index in txData'reverse_range loop
      txData(index) := TxD;
      wait for baudPeriod;
    end loop;
                                                            -- store information
    txWord <= to_integer(txData);
    txReceived <= '1';
    wait for 0 ns;
  end process receiveTxD;

  --============================================================================
                                                              -- monitor acesses
  startup <= '1', '0' after 1 ns;

  reportBusAccess: process(startup, rxReceived, txReceived)
  begin
    if startup = '1' then
      monitorTransaction <= pad(
        false, ' ', monitorTransaction'length,
        "idle"
      );
    elsif rising_edge(rxReceived) then
      monitorTransaction <= pad(
        false, ' ', monitorTransaction'length,
        "sent " & sprintf("%02X", rxWord)
      );
    elsif rising_edge(txReceived) then
      monitorTransaction <= pad(
        false, ' ', monitorTransaction'length,
        "received " & sprintf("%02X", txWord)
      );
    end if;
  end process reportBusAccess;

END ARCHITECTURE RTL;
