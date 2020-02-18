--==============================================================================
--
-- AHB general purpose input/outputs
--
-- Provides "ioNb" input/output signals .
--
--------------------------------------------------------------------------------
--
-- Write registers
--
-- 00, data register receives the values to drive the output lines.
-- 01, output enable register defines the signal direction:
--     when '1', the direction is "out".
--
--------------------------------------------------------------------------------
--
-- Read registers
-- 00, data register provides the values detected on the lines.
--

ARCHITECTURE RTL OF ahbGpio IS

  signal reset, clock: std_ulogic;
                                                         -- register definitions
  constant dataRegisterId: natural := 0;
  constant outputEnableRegisterId: natural := 1;

  signal addressReg: unsigned(addressBitNb(outputEnableRegisterId)-1 downto 0);
  signal writeReg: std_ulogic;
                                                            -- written registers
  subtype registerType is unsigned(ioNb-1 downto 0);
  signal dataOutRegister, outputEnableRegister: registerType;
                                                               -- read registers
  signal dataInRegister : registerType;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= not hReset_n;
  clock <= hClk;

  --============================================================================
                                                         -- address and controls
  storeControls: process(reset, clock)
  begin
    if reset = '1' then
      addressReg <= (others => '0');
      writeReg <= '0';
    elsif rising_edge(clock) then
      writeReg <= '0';
      if (hSel = '1') and (hTrans = transNonSeq) then
        addressReg <= hAddr(addressReg'range);
        writeReg <= hWrite;
      end if;
    end if;
  end process storeControls;

  --============================================================================
                                                                    -- registers
  storeWriteRegisters: process(reset, clock)
  begin
    if reset = '1' then
      dataOutRegister <= (others => '0');
      outputEnableRegister <= (others => '0');
    elsif rising_edge(clock) then
      if writeReg = '1' then
        case to_integer(addressReg) is
          when dataRegisterId         => dataOutRegister <= unsigned(hWData(dataOutRegister'range));
          when outputEnableRegisterId => outputEnableRegister <= unsigned(hWData(outputEnableRegister'range));
          when others => null;
        end case;
      end if;
    end if;
  end process storeWriteRegisters;

  ioOut <= std_ulogic_vector(dataOutRegister);
  ioEn <= std_ulogic_vector(outputEnableRegister);

  --============================================================================
                                                                -- data readback
  dataInRegister <= unsigned(ioIn);

  hRData <= std_ulogic_vector(resize(dataInRegister, hRData'length));
  hReady <= '1';  -- no wait state
  hResp  <= '0';  -- data OK


END ARCHITECTURE RTL;
