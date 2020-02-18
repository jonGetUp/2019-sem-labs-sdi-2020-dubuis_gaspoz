ARCHITECTURE test OF sdramController_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';

  signal ramAddr_int: natural := 0;
  signal ramDataOut_int: natural := 0;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  process
  begin
    ramRd <= '0';
    ramWr <= '0';
    ramEn <= '1';
                                                         -- wait for SDRAM ready
    wait for 154.3 us - now;
                                                 -- write AAAA at address 000010
    ramAddr_int <= 16#000010#;
    ramDataOut_int <= 16#AAAA#;
    ramWr <= '1', '0' after clockPeriod;
                                                         -- wait for SDRAM ready
    wait for 164.5 us - now;
                                                 -- write AAAA at address 000011
    ramAddr_int <= 16#000011#;
    ramDataOut_int <= 16#BBBD#;
    ramWr <= '1', '0' after clockPeriod;
                                                         -- wait for SDRAM ready
    wait for 196.1 us - now;
                                                -- read back from address 000010
    ramAddr_int <= 16#000010#;
    ramRd <= '1', '0' after clockPeriod;
--                                                         -- wait for SDRAM ready
--    wait for 130 us;
--                                                 -- write AAAA at address 000010
--    ramAddr_int <= 16#000010#;
--    ramDataOut_int <= 16#AAAA#;
--    ramWr <= '1', '0' after clockPeriod;
--                                                  -- read back from same address
--    wait for 10*clockPeriod;
--    ramRd <= '1', '0' after clockPeriod;
--                                                           -- wait for a refresh
--    wait for 140.3 us - now;
--                                                 -- write 5555 at address 600010
--    ramAddr_int <= 16#600020#;
--    ramDataOut_int <= 16#5555#;
--    ramWr <= '1', '0' after clockPeriod;
--                                                  -- read back from same address
--    wait for 1*clockPeriod;
--    ramRd <= '1', '0' after clockPeriod;
--                                                -- read back from address 600010
--    addr_from_up_int <= 16#600010#;
--    mem_read <= '1', '0' after clockPeriod;
--    wait for 10*clockPeriod;
--                                                   -- wait for 3 refresh periods
--    wait until falling_edge(dram_busy);
--    wait until falling_edge(dram_busy);
--    wait until falling_edge(dram_busy);
--                                                -- read back from address 000010
--    addr_from_up_int <= 16#000010#;
--    mem_read <= '1', '0' after clockPeriod;
--    wait for 10*clockPeriod;
                                                                 -- end of tests
    wait;
  end process;

  ------------------------------------------------------------------------------
                                                             -- address and data
  ramAddr <= to_unsigned(ramAddr_int, ramAddr'length);
  ramDataOut <= std_ulogic_vector(to_unsigned(ramDataOut_int, ramDataOut'length));

END ARCHITECTURE test;

