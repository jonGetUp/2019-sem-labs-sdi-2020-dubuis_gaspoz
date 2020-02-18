LIBRARY std;
  USE std.TEXTIO.all;
LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE RTL OF uvmAhbDriver IS

  constant flipflopDelay: time := 1 ns;

  signal hAddr1, hWData1, hWData2: natural := 0;
  signal hWrite1, hWrite2, hRead1, hRead2: std_ulogic := '0';

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  hReset_n <= not(reset);
  hClk <= clock;

  ------------------------------------------------------------------------------
                                                        -- interpret transaction
  interpretTransaction: process(driverTransaction)
    variable my_line : line;
    variable command_part : line;
  begin
    write(my_line, driverTransaction);
    read_first(my_line, command_part);
    if command_part.all = "write" then
      read_first(my_line, command_part);
      hAddr1 <= sscanf(command_part.all);
      read_first(my_line, command_part);
      hWData1 <= sscanf(command_part.all);
      hWrite1 <= '1', '0' after 1 ns;
    elsif command_part.all = "read" then
      read_first(my_line, command_part);
      hAddr1 <= sscanf(command_part.all);
      hRead1 <= '1', '0' after 1 ns;
    end if;
    deallocate(my_line);
  end process interpretTransaction;
                                              -- expand pulses to the next clock
  expandReadWrite: process
  begin
    hRead2 <= '0';
    hWrite2 <= '0';
    wait on hRead1, hWrite1;
    hRead2 <= hRead1;
    hWrite2 <= hWrite1;
    wait until rising_edge(clock);
  end process expandReadWrite;
                                           -- delay signals 1 or 2 clock periods
  synchAccess: process(reset, clock)
  begin
    if reset = '1' then
      hAddr <= (others => '0');
      hWData2 <= 0;
      hWData <= (others => '0');
      hWrite <= '0';
      hSel <= '0';
      hTrans <= transIdle;
    elsif rising_edge(clock) then
      hAddr <= to_unsigned(hAddr1, hAddr'length) after flipflopDelay;
      hWData2 <= hWData1;
      hWData <= std_ulogic_vector(to_unsigned(hWData2, hWData'length)) after flipflopDelay;
      hWrite <= hWrite2 after flipflopDelay;
      hSel <= hWrite2 or hRead2 after flipflopDelay;
      if (hWrite2 = '1') or (hRead2 = '1') then
        hTrans <= transNonSeq after flipflopDelay;
      else
        hTrans <= transIdle after flipflopDelay;
      end if;
    end if;
  end process synchAccess;

END ARCHITECTURE RTL;
