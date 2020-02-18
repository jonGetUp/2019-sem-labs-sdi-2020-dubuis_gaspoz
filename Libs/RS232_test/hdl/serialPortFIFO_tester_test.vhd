ARCHITECTURE test OF serialPortFIFO_tester IS

  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';

  constant rs232Frequency: real := baudRate;
  constant rs232Period: time := (1.0/rs232Frequency) * 1 sec;
  constant rs232WriteInterval: time := 10*rs232Period;

  signal rs232OutString : string(1 to 32);
  signal rs232SendOutString: std_uLogic;
  signal rs232SendOutDone: std_uLogic;
  signal rs232OutByte: character;
  signal rs232SendOutByte: std_uLogic;
  signal rs232OutByteReturned: std_ulogic_vector(rxData'range);

  signal rs232InString : string(1 to 32);
  signal rs232SendInString: std_uLogic;
  signal rs232SendInDone: std_uLogic;
  signal rs232InByte: character;
  signal rs232InByteReturned: character;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                -- RS232 Rx test
  process
  begin
    rs232SendOutString <= '0';
    wait for 4*rs232Period;

    rs232OutString <= "test 1                          ";
    rs232SendOutString <= '1', '0' after 1 ns;
    wait until rs232SendOutDone = '1';
    wait for rs232WriteInterval;

    rs232OutString <= "test 2                          ";
    rs232SendOutString <= '1', '0' after 1 ns;
    wait until rs232SendOutDone = '1';
    wait for rs232WriteInterval;

    rs232OutString <= "test 3                          ";
    rs232SendOutString <= '1', '0' after 1 ns;
    wait until rs232SendOutDone = '1';
    wait for rs232WriteInterval;

    rs232OutString <= "test 4                          ";
    rs232SendOutString <= '1', '0' after 1 ns;
    wait until rs232SendOutDone = '1';
    wait for rs232WriteInterval;

    wait;
  end process;

  readRxFifo: process
  begin
    rxRd <= '0';
    wait until falling_edge(rxEmpty);
    rxRd <= '1';
    wait for clockPeriod;
    rs232OutByteReturned <= rxData;
  end process readRxFifo;


  ------------------------------------------------------------------------------
                                                                -- RS232 Tx test
  process
  begin
    rs232SendInString <= '0';
    wait for 4*rs232Period;

    rs232InString <= "hello 1                         ";
    rs232SendInString <= '1', '0' after 1 ns;
    wait until rs232SendInDone = '1';
    wait for rs232WriteInterval;

    rs232InString <= "hello 2                         ";
    rs232SendInString <= '1', '0' after 1 ns;
    wait until rs232SendInDone = '1';
    wait for rs232WriteInterval;

    rs232InString <= "hello 3                         ";
    rs232SendInString <= '1', '0' after 1 ns;
    wait until rs232SendInDone = '1';
    wait for rs232WriteInterval;

    rs232InString <= "hello 4                         ";
    rs232SendInString <= '1', '0' after 1 ns;
    wait until rs232SendInDone = '1';
    wait for rs232WriteInterval;

    wait;
  end process;

  --============================================================================
                                                                   -- RS232 send
  rsSendSerialString: process
    constant rs232BytePeriod : time := 15*rs232Period;
    variable commandRight: natural;
  begin

    rs232SendOutByte <= '0';
    rs232SendOutDone <= '0';

    wait until rising_edge(rs232SendOutString);

    commandRight := rs232OutString'right;
    while rs232OutString(commandRight) = ' ' loop
      commandRight := commandRight-1;
    end loop;

    for index in rs232OutString'left to commandRight loop
      rs232OutByte <= rs232OutString(index);
      rs232SendOutByte <= '1', '0' after 1 ns;
      wait for rs232BytePeriod;
    end loop;

    rs232OutByte <= cr;
    rs232SendOutByte <= '1', '0' after 1 ns;
    wait for rs232BytePeriod;

    rs232SendOutDone <= '1';
    wait for 1 ns;

  end process rsSendSerialString;

  rsSendSerialByte: process
    variable txData: unsigned(7 downto 0);
  begin
    RxD <= '1';

    wait until rising_edge(rs232SendOutByte);
    txData := to_unsigned(character'pos(rs232OutByte), txData'length);

    RxD <= '0';
    wait for rs232Period;

    for index in txData'reverse_range loop
      RxD <= txData(index);
      wait for rs232Period;
    end loop;

  end process rsSendSerialByte;

  rsSendParallelString: process
    variable commandRight: natural;
  begin

    rs232SendInDone <= '0';
    txWr <= '0';

    wait until rising_edge(rs232SendInString);

    commandRight := rs232OutString'right;
    while rs232InString(commandRight) = ' ' loop
      commandRight := commandRight-1;
    end loop;

    wait until rising_edge(clock_int);
    for index in rs232InString'left to commandRight loop
      wait until rising_edge(clock_int);
      while txFull = '1' loop
        txWr <= '0';
        wait until rising_edge(clock_int);
      end loop;
      rs232InByte <= rs232InString(index);
      txWr <= '1';
    end loop;
    wait until rising_edge(clock_int);

    while txFull = '1' loop
      txWr <= '0';
      wait until rising_edge(clock_int);
    end loop;
    rs232InByte <= cr;
    txWr <= '1';
    wait until rising_edge(clock_int);
    txWr <= '0';

    rs232SendInDone <= '1';
    wait for 1 ns;

  end process rsSendParallelString;

  txData <= std_ulogic_vector(to_unsigned(character'pos(rs232InByte), txData'length));

  ------------------------------------------------------------------------------
                                                                -- RS232 receive
  rsReceiveByte: process
    variable rxData: unsigned(7 downto 0);
  begin
    wait until falling_edge(TxD);

    wait for 1.5 * rs232Period;

    for index in rxData'reverse_range loop
      rxData(index) := TxD;
      wait for rs232Period;
    end loop;

    rs232InByteReturned <= character'val(to_integer(rxData));

  end process rsReceiveByte;

END ARCHITECTURE test;
