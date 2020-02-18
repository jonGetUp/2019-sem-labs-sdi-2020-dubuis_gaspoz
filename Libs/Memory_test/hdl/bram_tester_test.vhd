ARCHITECTURE test OF bram_tester IS

  constant clockFrequencyA: real := 66.0E6;
  constant clockFrequencyB: real := 20.0E6;
  constant clockPeriodA: time := (1.0/clockFrequencyA) * 1 sec;
  constant clockPeriodB: time := (1.0/clockFrequencyB) * 1 sec;
  signal clockA_int: std_uLogic := '1';
  signal clockB_int: std_uLogic := '1';

  signal addressA_int: natural;
  signal dataA_int: integer;

  signal addressB_int: natural;
  signal dataB_int: integer;

BEGIN
  ------------------------------------------------------------------------------
                                                                       -- clocks
  clockA_int <= not clockA_int after clockPeriodA/2;
  clockA <= transport clockA_int after clockPeriodA*9/10;

  clockB_int <= not clockB_int after clockPeriodB/2;
  clockB <= transport clockB_int after clockPeriodB*9/10;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  portA: process
  begin
    enA <= '0';
    writeEnA <= '0';
    addressA_int <= 0;
    dataA_int <= 0;
                                                     -- read initial BRAM data
    wait for 5*clockPeriodA;
    addressA_int <= 40;
    enA <= '1';
    wait for clockPeriodA;
    enA <= '0';
                                                       -- write data on port A
    wait for 10*clockPeriodA;
    addressA_int <= 10;
    dataA_int <= 5;
    enA <= '1';
    writeEnA <= '1';
    wait for clockPeriodA;
    enA <= '0';
    writeEnA <= '0';

    wait;
  end process portA;

  addressA <= std_ulogic_vector(to_unsigned(addressA_int, addressA'length));
  dataInA <= std_ulogic_vector(to_signed(dataA_int, dataInA'length));

  portB: process
  begin
    enB <= '0';
    writeEnB <= '0';
    addressB_int <= 0;
    dataB_int <= 0;
                                                       -- write data on port B
    wait for 10*clockPeriodB;
    addressB_int <= 20;
    dataB_int <= 10;
    enB <= '1';
    writeEnB <= '1';
    wait for clockPeriodB;
    enB <= '0';
    writeEnB <= '0';
                                                -- read data written on port A
    wait for 2*clockPeriodB;
    addressB_int <= 10;
    enB <= '1';
    wait for clockPeriodB;
    enB <= '0';

    wait;
  end process portB;

  addressB <= std_ulogic_vector(to_unsigned(addressB_int, addressB'length));
  dataInB <= std_ulogic_vector(to_signed(dataB_int, dataInB'length));

END ARCHITECTURE test;
