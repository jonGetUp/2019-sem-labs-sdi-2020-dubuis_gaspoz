--LIBRARY std;
--  USE std.textio.ALL;
LIBRARY COMMON_TEST;
  USE COMMON_TEST.testUtils.all;

ARCHITECTURE test OF fifo_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_ulogic := '1';

  constant testInterval: time := 10*clockPeriod;
  signal dataIn_int: integer;
  signal read_int: std_ulogic;
  signal dataOffset: integer;

  signal dataValid: std_ulogic;
  signal dataRead: integer;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  process
    variable readIndex: integer;
  begin
    write <= '0';
    read_int <= '0';
    dataOffset <= -16#10#;
    wait for 5*clockPeriod;
    print(
      lf & lf & lf &
      "----------------------------------------------------------------" & lf &
      "Starting testbench" & lf &
      lf & lf
    );

    --..........................................................................
                                         -- full write / read after end of write
    wait for testInterval;
    print(
      "At time " & sprintf("%9.3tu", now) &
      ", full FIFO write direclty followed by full read" &
      lf & lf
    );
                                                                 -- write FIFO
    dataOffset <= dataOffset + 16#10#;
    wait until rising_edge(clock_int);
    write <= '1';
    for index in 0 to fifoDepth-1 loop
      dataIn_int <= dataOffset + index;
      wait for clockPeriod;
    end loop;
    write <= '0';
                                                                  -- read FIFO
    read_int <= '1';
    readIndex := 0;
    while empty = '0' loop
      assert unsigned(dataOut) = dataOffset + readIndex
        report "FIFO readback error" 
        severity error; 
      readIndex := readIndex + 1;
      wait until rising_edge(clock_int);
    end loop;
    read_int <= '0';

    --..........................................................................
                                            -- full write / read after some time
    wait for testInterval;
    print(
      "At time " & sprintf("%9.3tu", now) &
      ", full FIFO write and delay before read" &
      lf & lf
    );
                                                                 -- write FIFO
    dataOffset <= dataOffset + 16#10#;
    wait until rising_edge(clock_int);
    write <= '1';
    for index in 0 to fifoDepth-1 loop
      dataIn_int <= dataOffset + index;
      wait for clockPeriod;
    end loop;
    write <= '0';
                                                           -- wait before read
    wait for 4*clockPeriod;
                                                                  -- read FIFO
    read_int <= '1';
    readIndex := 0;
    while empty = '0' loop
      assert unsigned(dataOut) = dataOffset + readIndex
        report "FIFO readback error" 
        severity error; 
      readIndex := readIndex + 1;
      wait until rising_edge(clock_int);
    end loop;
    read_int <= '0';

    --..........................................................................
                                                          -- write / read direct
    wait for testInterval;
    print(
      "At time " & sprintf("%9.3tu", now) &
      ", full FIFO write with asynchronous direct read" &
      lf & lf
    );
                                                                 -- write FIFO
    dataOffset <= dataOffset + 16#10#;
    wait until rising_edge(clock_int);
    write <= '1', '0' after 8*clockPeriod;
    dataIn_int <= dataOffset + 16#00#,
                  dataOffset + 16#01# after 1*clockPeriod,
                  dataOffset + 16#02# after 2*clockPeriod,
                  dataOffset + 16#03# after 3*clockPeriod,
                  dataOffset + 16#04# after 4*clockPeriod,
                  dataOffset + 16#05# after 5*clockPeriod,
                  dataOffset + 16#06# after 6*clockPeriod,
                  dataOffset + 16#07# after 7*clockPeriod;
                                                                  -- read FIFO
    wait until empty = '0';
    read_int <= '1';
    readIndex := -1;
    while empty = '0' loop
      if readIndex >= 0 then
        assert unsigned(dataOut) = dataOffset + readIndex
          report "FIFO readback error" 
          severity error; 
      end if;
      readIndex := readIndex + 1;
      wait until rising_edge(clock_int);
    end loop;
    read_int <= '0';

    --..........................................................................
                                  -- write / read direct with clock period delay
    wait for testInterval;
    print(
      "At time " & sprintf("%9.3tu", now) &
      ", full FIFO write with synchronous direct read" &
      lf & lf
    );
                                                                 -- write FIFO
    dataOffset <= dataOffset + 16#10#;
    wait until rising_edge(clock_int);
    write <= '1', '0' after 8*clockPeriod;
    dataIn_int <= dataOffset + 16#00#,
                  dataOffset + 16#01# after 1*clockPeriod,
                  dataOffset + 16#02# after 2*clockPeriod,
                  dataOffset + 16#03# after 3*clockPeriod,
                  dataOffset + 16#04# after 4*clockPeriod,
                  dataOffset + 16#05# after 5*clockPeriod,
                  dataOffset + 16#06# after 6*clockPeriod,
                  dataOffset + 16#07# after 7*clockPeriod;
                                                                  -- read FIFO
    wait until empty = '0';
    wait until rising_edge(clock_int);
    read_int <= '1';
    readIndex := 0;
    while empty = '0' loop
      assert unsigned(dataOut) = dataOffset + readIndex
        report "FIFO readback error" 
        severity error; 
      readIndex := readIndex + 1;
      wait until rising_edge(clock_int);
    end loop;
    read_int <= '0';

    --..........................................................................
                                                     -- slow read sets FIFO full
    wait for testInterval;
    print(
      "At time " & sprintf("%9.3tu", now) &
      ", slow reading sets FIFO full and requires waiting before writing on" &
      lf & lf
    );
                                                  -- prepare slow FIFO reading
    wait until rising_edge(clock_int);
    wait for 2*clockPeriod;
    read_int <= '1' after  4*clockPeriod,
            '0' after  5*clockPeriod,
            '1' after 14*clockPeriod,
            '0' after 15*clockPeriod,
            '1' after 24*clockPeriod,
            '0' after 25*clockPeriod,
            '1' after 34*clockPeriod,
            '0' after 35*clockPeriod,
            '1' after 44*clockPeriod,
            '0' after (45+2*fifoDepth-5)*clockPeriod;
                                                         -- write 2*FIFO depth
    dataOffset <= dataOffset + 16#10#;
    wait until rising_edge(clock_int);
    for index in 0 to 2*fifoDepth-1 loop
      dataIn_int <= dataOffset + index;
      if full = '1' then
        wait until full = '0';
        wait for clockPeriod/8;
      end if;
      write <= '1';
      wait until rising_edge(clock_int);
      write <= '0';
    end loop;

    --..........................................................................
                                                              -- write over full
    wait for testInterval;
    print(
      "At time " & sprintf("%9.3tu", now) &
      ", attempt to write after FIFO full" &
      lf & lf
    );
                                                                 -- write FIFO
    dataOffset <= dataOffset + 16#10#;
    wait until rising_edge(clock_int);
    write <= '1';
    for index in 0 to fifoDepth+3 loop
      dataIn_int <= dataOffset + index;
      wait for clockPeriod;
    end loop;
    write <= '0';

    --..........................................................................
                                                      -- read FIFO once too much
    print(
      "At time " & sprintf("%9.3tu", now) &
      ", attempt to read after FIFO empty" &
      lf & lf
    );
    read_int <= '1';
    wait for clockPeriod;
    wait until empty = '1';
    wait for clockPeriod;
    read_int <= '0';
                                                              -- read when empty
    wait until rising_edge(clock_int);
    wait for 2*clockPeriod;
    read_int <= '1';
    wait for 2*clockPeriod;
    read_int <= '0';
    
    --..........................................................................
                                                              -- read constantly
    wait for testInterval;
    print(
      "At time " & sprintf("%9.3tu", now) &
      ", reading FIFO constantly (data valid when empty = '0')" &
      lf & lf
    );

    dataOffset <= dataOffset + 16#10#;
    wait until rising_edge(clock_int);
    read_int <= '1';
    wait for 2*clockPeriod;
    wait until rising_edge(clock_int);
    readIndex := -1;
    write <= '1';
    for index in 0 to fifoDepth-1 loop
      if empty = '0' then
        readIndex := readIndex + 1;
      end if;
      if (readIndex >= 0) and (empty = '0') then
        assert unsigned(dataOut) = dataOffset + readIndex
          report "FIFO readback error" 
          severity error; 
      end if;
      dataIn_int <= dataOffset + index;
      wait until rising_edge(clock_int);
    end loop;
    write <= '0';

    wait until empty = '1';
    wait for 2*clockPeriod;
    read_int <= '0';
    
    --..........................................................................
                                                -- full write / read with breaks
    wait for testInterval;
    print(
      "At time " & sprintf("%9.3tu", now) &
      ", reading FIFO with breaks" &
      lf & lf
    );
                                                                 -- write FIFO
    dataOffset <= dataOffset + 16#10#;
    wait until rising_edge(clock_int);
    write <= '1';
    for index in 0 to fifoDepth-1 loop
      dataIn_int <= dataOffset + index;
      wait for clockPeriod;
    end loop;
    write <= '0';
                                                           -- wait before read
    wait for 2*clockPeriod;
                                                                  -- read FIFO
    wait until rising_edge(clock_int);
    readIndex := 0;
    for index in 0 to fifoDepth/4-1 loop
      read_int <= '1';
      for rdIndex in 1 to 2 loop
        assert unsigned(dataOut) = dataOffset + readIndex
          report "FIFO readback error" 
          severity error; 
        readIndex := readIndex + 1;
        wait until rising_edge(clock_int);
      end loop;
      read_int <= '0';
      wait for 2*clockPeriod;
    end loop;
    read_int <= '1';
    while empty = '0' loop
      assert unsigned(dataOut) = dataOffset + readIndex
        report "FIFO readback error" 
        severity error; 
      readIndex := readIndex + 1;
      wait until rising_edge(clock_int);
    end loop;
    read_int <= '0';
    --..........................................................................
                                                                 -- end of tests
    wait for testInterval;
    assert false 
      report "END SIMULATION" 
      severity failure; 
    wait;
  end process;

  dataIn <= std_ulogic_vector(to_signed(dataIn_int, dataIn'length));
  read <= read_int;

  dataValid <= '1' when (read_int = '1') and (empty = '0')
    else '0';
  dataRead <= to_integer(signed(dataOut)) when dataValid = '1'
    else 0;

END ARCHITECTURE test;
