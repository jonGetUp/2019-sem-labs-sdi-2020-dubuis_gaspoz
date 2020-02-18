PACKAGE BODY ahbLite IS

  function addressBitNb (addressNb : natural) return natural is
    variable powerOfTwo, bitNb : natural;
  begin
    powerOfTwo := 1;
    bitNb := 0;
    while powerOfTwo <= addressNb loop
      powerOfTwo := 2 * powerOfTwo;
      bitNb := bitNb + 1;
    end loop;
    return bitNb;
  end addressBitNb;

END ahbLite;
