ARCHITECTURE Spartan2 OF blockRAM IS

  subtype register_type is std_ulogic_vector(dataBitNb-1 downto 0);
  type memory_type is array (0 to 2**addressBitNb-1) of register_type;

  signal memoryArray : memory_type;

BEGIN

  portA: process(clock)
  begin
    if rising_edge(clock) then
      if (en = '1') then
        if (write = '1') then
          memoryArray(to_integer(addr)) <= dataIn;
        end if;
        if reset = '1' then
          dataOut <= (others => '0');
        elsif (write = '1') then
          dataOut <= dataIn;
        else
          dataOut <= memoryArray(to_integer(addr));
        end if;
      end if;
    end if;
  end process portA;

END ARCHITECTURE Spartan2;

