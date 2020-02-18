ARCHITECTURE test OF waveformGen_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';

begin
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;
  reset <= '1', '0' after 2*clockPeriod;

  ------------------------------------------------------------------------------
                                                                       -- enable
  en <= '0', '1' after 100 us;

  ------------------------------------------------------------------------------
                                                            -- frequency control
  step <= to_unsigned(2**(step'length-13), step'length);

END ARCHITECTURE test;

