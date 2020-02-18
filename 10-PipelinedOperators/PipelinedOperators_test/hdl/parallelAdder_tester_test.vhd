ARCHITECTURE test OF parallelAdder_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';
  signal sReset: std_uLogic := '1';

  constant aMax: signed(a'range) := (a'high => '0', others => '1');
  constant aIncr: signed(a'range) := shift_right(aMax, 4)+1;
  constant bIncr: signed(b'range) := shift_right(aMax, 4)+1;
  signal a_int, b_int, sum_int: signed(a'range);

BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  sReset <= '1', '0' after 2*clockPeriod;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  process
  begin
    a_int <= (a_int'high => '1', others => '0');
    b_int <= (b_int'high => '1', others => '0');
    wait until sReset = '0';
                                                                  -- data values
    while a_int < aMax-aIncr loop
      a_int <= a_int + aIncr;
      b_int <= b_int + bIncr;
      wait until rising_edge(sClock);
      assert sum = a_int + b_int
        report "sum is wrong !"
        severity error;
    end loop;
                                                              -- stop simulation
    assert false
      report cr & cr &
        "End of Simulation" &
        cr
      severity failure;
    wait;
  end process;

  cIn <= '0';
  a <= a_int;
  b <= b_int;
  sum_int <= a_int + b_int;

END ARCHITECTURE test;
