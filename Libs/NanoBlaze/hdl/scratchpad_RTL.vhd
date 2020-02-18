ARCHITECTURE RTL OF scratchpad IS

  subtype memoryWordType is signed(dataOut'range);
  type memoryArrayType is array (0 to 2**addr'length-1) of memoryWordType;

  signal memoryArray : memoryArrayType;

BEGIN

  process (clock)
  begin
    if rising_edge(clock) then
      if write = '1' then
        memoryArray(to_integer(addr)) <= dataIn;
      end if;
    end if;
  end process;

  dataOut <= memoryArray(to_integer(addr));

END ARCHITECTURE RTL;
