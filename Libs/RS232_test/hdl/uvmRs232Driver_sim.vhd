LIBRARY std;
  USE std.TEXTIO.all;
LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE RTL OF uvmRs232Driver IS

  signal baudRate_int: real;
  signal baudPeriod: time;
  constant uartDataBitNb: positive := 8;
  signal rxData: natural;
  signal sendByte: std_ulogic := '0';

BEGIN
  ------------------------------------------------------------------------------
                                                        -- interpret transaction
  interpretTransaction: process(driverTransaction)
    variable my_line : line;
    variable command_part : line;
    variable baudRate_nat : natural;
  begin
    write(my_line, driverTransaction);
    rm_side_separators(my_line);
    read_first(my_line, command_part);
    if command_part.all = "baud" then
      read(my_line, baudRate_nat);
      baudRate_int <= real(baudRate_nat);
    elsif command_part.all = "send" then
      rxData <= sscanf(my_line.all);
      sendByte <= '1', '0' after 1 ns;
    end if;
    deallocate(my_line);
  end process interpretTransaction;

  baudRate <= baudRate_int;
  baudPeriod <= 1.0/baudRate_int * 1 sec;

  ------------------------------------------------------------------------------
                                                        -- send byte on RxD line
  uartSendByte: process
    variable rxData_unsigned: unsigned(uartDataBitNb-1 downto 0);
  begin
                                                                -- default value
    RxD <= '1';
                                                             -- wait for trigger
    wait until rising_edge(sendByte);
    rxData_unsigned := to_unsigned(rxData, rxData_unsigned'length);
                                                               -- send start bit
    RxD <= '0';
    wait for baudPeriod;
                                                               -- send data bits
    for index in rxData_unsigned'reverse_range loop
      RxD <= rxData_unsigned(index);
      wait for baudPeriod;
    end loop;
  end process uartSendByte;

END ARCHITECTURE RTL;
