ARCHITECTURE test OF sineGen_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';

BEGIN

  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;

  reset <= '1', '0' after 2*clockPeriod;

  ------------------------------------------------------------------------------
                                                                     -- controls
  step <= to_unsigned(1, step'length);

END ARCHITECTURE test;
