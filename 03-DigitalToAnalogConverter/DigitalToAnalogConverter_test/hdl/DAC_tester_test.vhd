library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF DAC_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';

  signal sineFrequency: real := 20.0E3;
  signal tReal: real := 0.0;
  signal outAmplitude: real := 1.0;
  signal outReal: real := 0.0;
  signal outUnsigned: unsigned(parallelIn'range);

BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;
  reset <= '1', '0' after 2*clockPeriod;

  ------------------------------------------------------------------------------
                                                                 -- time signals
  process(sClock)
  begin
    if rising_edge(sClock) then
      tReal <= tReal + 1.0/clockFrequency;
    end if;
  end process;

  outReal <= outAmplitude * ( sin(2.0*math_pi*sineFrequency*tReal) + 1.0) / 2.0;

  outUnsigned <= to_unsigned(integer(outReal * real(2**(outUnsigned'length)-1)), outUnsigned'length);
  parallelIn <= outUnsigned;
--  parallelIn <= shift_left(to_unsigned(1, parallelIn'length), parallelIn'length-1);
--  parallelIn <= shift_left(to_unsigned(3, parallelIn'length), parallelIn'length-2);

END ARCHITECTURE test;
