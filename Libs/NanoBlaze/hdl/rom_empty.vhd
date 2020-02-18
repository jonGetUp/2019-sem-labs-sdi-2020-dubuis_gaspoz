ARCHITECTURE empty OF programRom IS

  subtype memoryWordType is std_ulogic_vector(dataOut'range);
  type memoryArrayType is array (0 to 2**address'length-1) of memoryWordType;

  signal memoryArray : memoryArrayType := (
    others => (others => '0')
  );

BEGIN

  process (clock)
  begin
    if rising_edge(clock) then
      if en = '1' then
        dataOut <= (others => '0');
      end if;
    end if;
  end process;

END ARCHITECTURE empty;
