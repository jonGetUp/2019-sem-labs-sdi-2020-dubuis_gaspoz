ARCHITECTURE test OF pipelineAdder_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';
  signal sReset: std_uLogic := '1';

  constant pipeDelay: positive := 4;
  constant aMax: signed(a'range) := (a'high => '0', others => '1');
  constant aIncr: signed(a'range) := shift_right(aMax, 3)+1 + 32;
  constant bIncr: signed(b'range) := shift_right(aMax, 3)+1 + 32;
  signal a_int, b_int, sumNoPipe: signed(a'range);

  type sumArrayType is array(1 to stageNb-1) of signed(sumNoPipe'range);
  signal sumArray : sumArrayType := (others => (others => '0'));

BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;
  sReset <= '1', '0' after 2*clockPeriod;
  reset <= sReset;

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
    end loop;
                                                              -- stop simulation
    for index in 1 to pipeDelay loop
      wait until rising_edge(sClock);
    end loop;
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
  sumNoPipe <= a_int + b_int;

  ------------------------------------------------------------------------------
                                                                    -- delay sum
  process(sClock)
  begin
    if rising_edge(sClock) then
      sumArray(1) <= sumNoPipe;
      sumArray(2 to sumArray'length) <= sumArray(1 to sumArray'length-1);
      assert sum = sumArray(sumArray'length-1)
        report "sum is wrong !"
        severity error;
    end if;
  end process;

END ARCHITECTURE test;
