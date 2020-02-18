USE std.textio.all;

ARCHITECTURE Spartan3E OF blockRAM IS

  subtype registerType is std_ulogic_vector(dataBitNb-1 downto 0);
  type memoryType is array (0 to 2**addressBitNb-1) of registerType;

  -- Define function to create initvalue signal
  impure function ReadRamContentFromFile(ramContentFileSpec : in string) return memoryType is
    FILE     ramContentFile     : text open read_mode is ramContentFileSpec;
    variable ramContentFileLine : line;
    variable ramContent         : memoryType;
    variable ramCurrentWord     : bit_vector(registerType'range);
    variable index              : natural := 0; --241;
  begin
--    for index in ramContent'range loop
    while not endfile(ramContentFile) loop
      readline(ramContentFile, ramContentFileLine);
      read(ramContentFileLine, ramCurrentWord);
      ramContent(index) := std_ulogic_vector(to_stdlogicvector(ramCurrentWord));
      index := index + 1;
    end loop;
    return ramContent;
  end function;

  shared variable memoryArray: memoryType := ReadRamContentFromFile(initFileSpec);

BEGIN

  portA: process(clock)
  begin
    if rising_edge(clock) then
      if (en = '1') then
        if (write = '1') then
          memoryArray(to_integer(addr)) := dataIn;
          dataOut <= dataIn;
        else
          dataOut <= memoryArray(to_integer(addr));
        end if;
      end if;
    end if;
  end process portA;

END ARCHITECTURE Spartan3E;
