LIBRARY BoardTester_test;
  USE BoardTester_test.testUtils.all;

ARCHITECTURE test OF flash_tester IS

  constant T_W2: time :=  0 ns;
  constant T_W3: time := 70 ns;
  constant T_W4: time := 50 ns;
  constant T_W5: time := 55 ns;
  constant T_W6: time := 10 ns;
  constant T_R3: time := 120 ns;

  signal addr: natural;
  signal data: integer;

  signal writeFlash: std_ulogic := '0';
  signal readFlash: std_ulogic := '0';

  constant separator : string(1 to 80) := (others => '-');
  constant indent    : string(1 to  2) := (others => ' ');

BEGIN

  ------------------------------------------------------------------------------
  -- Test
  ------------------------------------------------------------------------------
  process
  begin
    RP_n <= '1';
    wait for 1 us;
    print(cr & separator);
                                                               --  erase block 0
    print(sprintf("%tu", now) & ": Erasing block 0");
    addr <= 16#10000#;
    data <= 16#20#;
    writeFlash <= '1', '0' after 1 ns;
    wait for 100 ns;
    data <= 16#D0#;
    writeFlash <= '1', '0' after 1 ns;
    wait for 2 us;
                                                                --  program word
    print(sprintf("%tu", now) & ": Writing data into Flash");
    addr <= 16#0000#;
    data <= 16#0040#;
    writeFlash <= '1', '0' after 1 ns;
    wait for 100 ns;
    addr <= 16#0010#;
    data <= 16#CAFE#;
    writeFlash <= '1', '0' after 1 ns;
    wait for 2 us;
                                                                   --  read word
    print(sprintf("%tu", now) & ": Reading data from Flash");
    addr <= 16#0000#;
    readFlash <= '1', '0' after 1 ns;
    wait for 500 ns;
                                                                   --  read word
    print(sprintf("%tu", now) & ": Reading data from Flash");
    addr <= 16#0010#;
    readFlash <= '1', '0' after 1 ns;
    wait for 500 ns;

    wait;
  end process;

  ------------------------------------------------------------------------------
  -- Board connections
  ------------------------------------------------------------------------------
  CE(2 downto 1) <= (others => '0');
  BYTE_n <= '1';


  ------------------------------------------------------------------------------
  -- Write access
  ------------------------------------------------------------------------------
  process
  begin
    CE(0) <= '1';
    WE_N <= '1';
    OE_N <= '1';
    DQ <= (others => 'Z');
    wait on writeFlash, readFlash;
    if rising_edge(writeFlash) then
      A <= to_unsigned(addr, A'length) after T_W3 - T_W5;
      DQ <= std_logic_vector(to_unsigned(data, DQ'length)) after T_W3 - T_W4;
      CE(0) <= '0';
      wait for T_W2;
      WE_N <= '0';
      wait for T_W3;
      WE_N <= '1';
      wait for T_W6;
--      CE(0) <= '1';
    elsif rising_edge(readFlash) then
      OE_N <= '0';
      A <= to_unsigned(addr, A'length);
      CE(0) <= '0';
      wait for T_R3 + 10 ns;
--      CE(0) <= '1';
    end if;
  end process;

END ARCHITECTURE test;

