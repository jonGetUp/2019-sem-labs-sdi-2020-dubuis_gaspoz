ARCHITECTURE test OF nanoBlaze_tester IS

  constant clockFrequency: real := 100.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';

  signal dataReg: std_ulogic_vector(dataOut'range);

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9.0/10.0;

  ------------------------------------------------------------------------------
                                                                       -- enable
  en <= '1';

  ------------------------------------------------------------------------------
                                                                         -- data
  storeData: process(clock_int)
  begin
    if rising_edge(clock_int) then
      if writeStrobe = '1' then
        dataReg <= dataOut;
      end if;
    end if;
  end process storeData;

  dataIn <= not dataReg;

  ------------------------------------------------------------------------------
                                                               -- error checking
  checkBus: process(clock_int)
  begin
    if rising_edge(clock_int) then
      if writeStrobe = '1' then
        if (dataAddress = 0) and (unsigned(dataOut) = 0) then
          assert false
            report "Testbench reports error (output value 0 at address 0)"
            severity failure;
        end if;
        if (dataAddress = 0) and (unsigned(dataOut) = 1) then
          assert false
            report
              cr & cr &
              "--------------------------------------------------------------------------------" & cr &
              "Testbench reports successful end of simulation (output value 1 at address 0)" & cr &
              "--------------------------------------------------------------------------------" & cr &
              cr
            severity failure;
        end if;
      end if;
    end if;
  end process checkBus;

END ARCHITECTURE test;
