LIBRARY BoardTester_test;
  USE BoardTester_test.testUtils.all;

ARCHITECTURE test OF flashController_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';

  signal flashAddr_int: natural := 0;
  signal flashDataOut_int: natural := 0;

  signal refreshEn: std_uLogic := '0';

  constant separator : string(1 to 80) := (others => '-');
  constant indent    : string(1 to  2) := (others => ' ');

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                 -- flash access
  process
  begin
    flashRd <= '0';
    flashWr <= '0';
    flashEn <= '1';
    wait for 1 us;
    print(cr & separator);
                                                               --  erase block 0
    print(sprintf("%tu", now) & ": Erasing block 0");
    flashAddr_int <= 16#10000#;
    flashDataOut_int <= 16#0020#;
    flashWr <= '1', '0' after clockPeriod;
    wait until falling_edge(flashDataValid);
    wait for clockPeriod/10;
    flashDataOut_int <= 16#00D0#;
    flashWr <= '1', '0' after clockPeriod;
    wait for 2 us;
                                                                --  program word
    print(sprintf("%tu", now) & ": Writing data into Flash");
    flashAddr_int <= 16#0000#;
    flashDataOut_int <= 16#0040#;
    flashWr <= '1', '0' after clockPeriod;
    wait until falling_edge(flashDataValid);
    wait for clockPeriod/10;
    flashAddr_int <= 16#0010#;
    flashDataOut_int <= 16#CAFE#;
    flashWr <= '1', '0' after clockPeriod;
    wait for 2 us;
                                                                   --  read word
    print(sprintf("%tu", now) & ": Reading data from Flash");
    flashAddr_int <= 16#0000#;
    flashRd <= '1', '0' after clockPeriod;
    wait for 1 us;
                                                                   --  read word
    print(sprintf("%tu", now) & ": Reading data from Flash");
    flashAddr_int <= 16#000F#;
    flashRd <= '1', '0' after clockPeriod;
    wait for 500 ns;
    flashAddr_int <= 16#0010#;
    flashRd <= '1', '0' after clockPeriod;
    wait for 500 ns;
    flashAddr_int <= 16#0011#;
    flashRd <= '1', '0' after clockPeriod;
    wait for 500 ns;

    wait;
  end process;

  ------------------------------------------------------------------------------
                                                             -- address and data
  flashAddr <= to_unsigned(flashAddr_int, flashAddr'length);
  flashDataOut <= std_ulogic_vector(to_unsigned(flashDataOut_int, flashDataOut'length));

  ------------------------------------------------------------------------------
                                                              -- memory bus hold
  refreshEn <= '1' after 15*clockPeriod when refreshEn = '0'
    else '0' after clockPeriod;
  memBusEn_n <= refreshEn;

END ARCHITECTURE test;

