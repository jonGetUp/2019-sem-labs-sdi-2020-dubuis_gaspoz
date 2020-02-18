ARCHITECTURE test OF ahbLite_tester IS
                                                              -- reset and clock
  constant clockFrequency: real := 100.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';
                                                              -- register access
  signal registerAddress: natural;
  signal registerData: integer;
  signal registerWrite: std_uLogic;
  signal registerRead: std_uLogic;
                                                           -- AHB lite registers
  signal addressReg: unsigned(hAddr'range);
  signal writeReg: std_uLogic;
  signal selPeriph1Reg: std_uLogic;
  signal selPeriph2Reg: std_uLogic;
  signal hSel: std_uLogic;
  constant registerNb: positive := 2*periph2BaseAddress;
  subtype registerType is std_uLogic_vector(hWdata'range);
  type registerArrayType is array (registerNb-1 downto 0) of registerType;
  signal registerArray: registerArrayType;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 4*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9.0/10.0;


  ------------------------------------------------------------------------------
                                                                -- test sequence
  testSequence: process
  begin
    registerAddress <= 0;
    registerData <= 0;
    registerWrite <= '0';
    registerRead <= '0';
    wait for 100 ns;
                                                     -- write periph1 register 0
    registerAddress <= 0;
    registerData <= 1;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 8*clockPeriod;
                                                     -- write periph1 register 1
    registerAddress <= 1;
    registerData <= 2;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 8*clockPeriod;
                                                     -- write periph2 register 0
    registerAddress <= periph2BaseAddress;
    registerData <= periph2BaseAddress + 1;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 2*clockPeriod;
                                                     -- write periph2 register 1
    registerAddress <= periph2BaseAddress + 1;
    registerData <= periph2BaseAddress + 2;
    registerWrite <= '1', '0' after clockPeriod;
    wait for 8*clockPeriod;
                                                      -- read periph1 register 0
    registerAddress <= 0;
    registerRead <= '1', '0' after clockPeriod;
    wait for 8*clockPeriod;
                                                      -- read periph2 register 0
    registerAddress <= periph2BaseAddress;
    registerRead <= '1', '0' after clockPeriod;
    wait for 8*clockPeriod;

    wait;
  end process testSequence;

  --============================================================================
                                                    -- microprocessor bus access
  busAccess: process
    variable writeAccess: boolean;
  begin
    upAddress <= (others => '-');
    upDataOut <= (others => '-');
    upReadStrobe <= '0';
    upWriteStrobe <= '0';
                                                         -- wait for transaction
    wait on registerWrite, registerRead;
    if not(hReset_n) = '0' then
      writeAccess := false;
      if rising_edge(registerWrite) then
        writeAccess := true;
      end if;
                                                      -- single-cycle bus access
      wait until rising_edge(clock_int);
      upAddress <= to_unsigned(registerAddress, hAddr'length);
      if writeAccess then
        upWriteStrobe <= '1';
        upDataOut <= std_uLogic_vector(to_signed(registerData, upDataOut'length));
      else
        upReadStrobe <= '1';
      end if;
      wait until rising_edge(clock_int);
    end if;
  end process;

  --============================================================================
                                                               -- AHB bus access
  hSel <= hSelPeriph1 or hSelPeriph2;
                                                         -- address and controls
  storeControls: process(hReset_n, hClk)
  begin
    if not(hReset_n) = '1' then
      addressReg <= (others => '0');
      writeReg <= '0';
      selPeriph1Reg <= '0';
      selPeriph2Reg <= '0';
    elsif rising_edge(hClk) then
      writeReg <= '0';
      if (hSel = '1') and (hTrans = transNonSeq) then
        addressReg <= hAddr;
        writeReg <= hWrite;
        selPeriph1Reg <= hSelPeriph1;
        selPeriph2Reg <= hSelPeriph2;
      end if;
    end if;
  end process storeControls;
                                                              -- write registers
  storeRegisters: process(hReset_n, hClk)
  begin
    if not(hReset_n) = '1' then
      registerArray <= (others => (others => '0'));
    elsif rising_edge(hClk) then
      if writeReg = '1' then
        registerArray(to_integer(addressReg)) <= hWData;
      end if;
    end if;
  end process storeRegisters;
                                                                -- read egisters
  hRDataPeriph1 <= registerArray(to_integer(addressReg))
    when addressReg < periph2BaseAddress
    else (others => '-');
  hReadyPeriph1 <= '1';  -- no wait state
  hRespPeriph1  <= '0';  -- data OK

  hRDataPeriph2 <= registerArray(to_integer(addressReg))
    when addressReg >= periph2BaseAddress
    else (others => '-');
  hReadyPeriph2 <= '1';  -- no wait state
  hRespPeriph2  <= '0';  -- data OK

END ARCHITECTURE test;
