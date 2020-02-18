ARCHITECTURE RTL OF branchStack IS

  subtype progCounterType is unsigned(progCounter'range);
  type progCounterArrayType is array (0 to 2**stackPointerBitNb) of progCounterType;
  signal progCounterArray : progCounterArrayType;

  signal writePointer : unsigned(stackPointerBitNb-1 downto 0);
  signal readPointer  : unsigned(stackPointerBitNb-1 downto 0);

BEGIN
  ------------------------------------------------------------------------------
                                                               -- stack pointers
  updateStackPointer: process(reset, clock)
  begin
    if reset = '1' then
      writePointer <= (others => '0');
    elsif rising_edge(clock) then
      if storePC = '1' then
        writePointer <= writePointer + 1;
      elsif prevPC = '1' then
        writePointer <= writePointer - 1;
      end if;
    end if;
  end process updateStackPointer;

  readPointer <= writePointer - 1;

  ------------------------------------------------------------------------------
                                                       -- program counters stack
  updateStack: process(reset, clock)
  begin
    if rising_edge(clock) then
      if storePc = '1' then
        progCounterArray(to_integer(writePointer)) <= progCounter;
      end if;
      storedProgCounter <= progCounterArray(to_integer(readPointer));
    end if;
  end process updateStack;

END ARCHITECTURE RTL;
