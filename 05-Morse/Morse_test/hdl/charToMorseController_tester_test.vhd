LIBRARY std;
  USE std.textio.all;
LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE test OF charToMorseController_tester IS
                                                              -- clock and reset
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';
  signal sReset: std_uLogic := '1';
                                                              -- character input
  constant textToSend : string := "tea time";
  constant charInputDelay : time := 200 us;
  signal writePointer, readPointer : integer := 0;
  signal fifoDataAvailable: std_uLogic := '0';

BEGIN
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;
  sReset <= '1', '0' after 2*clockPeriod;
  reset <= sReset;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  testSequence: process
  begin
                                                              -- send characters
    for index in 1 to textToSend'length loop
      wait for charInputDelay;
      writePointer <= writePointer + 1;
    end loop;
                                                            -- end of fifo input
    print(cr & cr);
    assert false
    report "End of text"
      severity note;
    wait;
  end process testSequence;

  ------------------------------------------------------------------------------
                                                              -- fifo simulation
  fifo: process
  begin
                                                              -- wait for action
    wait until rising_edge(sClock);
                                                             -- add char in fifo
    if readChar = '1' then
      readPointer <= readPointer + 1;
    end if;
                                                            -- end of simulation
    if readPointer = textToSend'length then
      wait for charInputDelay;
      print(cr & cr);
      assert false
      report "End of simulation"
        severity failure;
    end if;
  end process fifo;

  char <= std_ulogic_vector(to_unsigned(
    character'pos(textToSend(readPointer+1)), char'length
  )) when (readPointer < textToSend'length) and (fifoDataAvailable = '1')
  else (others => '-');

  fifoDataAvailable <= '1' when readPointer < writePointer
  else '0';
  charNotReady <= not fifoDataAvailable;

END ARCHITECTURE test;
