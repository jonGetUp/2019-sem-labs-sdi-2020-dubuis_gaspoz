ARCHITECTURE RTL OF registerFile IS

  subtype registerType is signed(registersIn'range);
  type registerArrayType is array (0 to 2**registerAddressBitNb-1) of registerType;
  signal registerArray : registerArrayType;

BEGIN
  ------------------------------------------------------------------------------
                                                           -- write to registers
  updateRegister: process(reset, clock)
  begin
    if reset = '1' then
      registerArray <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if regWrite = '1' then
        registerArray(to_integer(addrA)) <= registersIn;
      end if;
    end if;
  end process updateRegister;

  ------------------------------------------------------------------------------
                                                          -- read from registers
  opA <= registerArray(to_integer(addrA));
  opB <= registerArray(to_integer(addrB));

END ARCHITECTURE RTL;
